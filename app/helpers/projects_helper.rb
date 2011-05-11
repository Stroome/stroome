module ProjectsHelper
end



########
require 'ap'

# A callback class to sync Project & Clip info with video service.
class SyncWithVideoService

  def initialize(vid_service, search_url_builder=nil)
    @vid_service = vid_service
    @search_url_builder = search_url_builder
  end

  ### callbacks

  def before_create(project)
    if not project.remixed_from.nil?
      add_remix(project)
    elsif not project.with_clip_video_id.nil?
      add_mix(project) and append_clip(project, project.with_clip_video_id)
    else
      add_mix(project)
    end
  end


  ### methods

  def append_clip(project, clip_video_id)
    log = project.logger
    username = project.user.username

    begin
      log.info "[append_clip] appending entry to mix in remote service."
      mix_id = project.video_id
      mix = @vid_service.append_entry_to_mix(mix_id, clip_video_id, username)
    rescue => ex
      log.error "[append_clip] failed to append entry(id:#{ clip_video_id }) to mix(id:#{ mix_id }). Reason:"
      log.error ex.message
      log.error mix.inspect if not mix.nil?
      log.ap ex.backtrace
      return false
    end

    log.info "[append_clip] updating project video info."
    update_project_video_info(project, mix)

    log.info "[append_clip] fetching video entries used in mix from remote service."
    begin
      entries = @vid_service.all_video_entries_used_in_mix(mix.id, username)
    rescue => ex
      log.error "[append_clip] failed to fetch entries used in mix. Reason:"
      log.error ex.message
      log.error mix.inspect if not mix.nil?
      log.ap ex.backtrace
      return false
    end

    log.info "[append_clip] updating project clips info, incl updating clips in db."
    update_project_clips_info(project, entries, project.user.id)


    log.info "[append_clip] done."
    true
  end

  def sync_project_video_n_clips_info(project, log)
    username = project.user.username

    begin
      log.info "[vid_sync] get mix from remote service."
      mix_id = project.video_id
      mix = @vid_service.get_mix(mix_id, username)
    rescue => ex
      log.error "[vid_sync] failed to get mix(id:#{ mix_id }). Reason:"
      log.error ex.message
      log.error mix.inspect if not mix.nil?
      log.ap ex.backtrace
      return false
    end

    log.info "[vid_sync] updating project video info."
    update_project_video_info(project, mix)

    log.info "[vid_sync] fetching video entries used in mix from remote service."
    begin
      entries = @vid_service.all_video_entries_used_in_mix(mix.id, username)
    rescue => ex
      log.error "[vid_sync] failed to fetch entries used in mix. Reason:"
      log.error ex.message
      log.error mix.inspect if not mix.nil?
      log.ap ex.backtrace
      return false
    end

    log.info "[vid_sync] updating project clips info, incl updating clips in db."
    update_project_clips_info(project, entries, project.user.id, log)

    log.info "[vid_sync] saving project."
    unless project.save
      log.info "[vid_syn] #{ project.errors }"
    end

    log.info "[vid_sync] done."
    true
  end

  def add_remix(project)
    log = project.logger
    username = project.user.username

    begin
      mix_id = project.remixed_from.video_id
      log.info "[add_remix] cloning a mix from remote service."
      mix = @vid_service.clone_mix(mix_id, username)
    rescue => ex
      log.error "[add_remix] failed to clone mix (id:#{ mix_id }). Reason:"
      log.error ex.message
      log.error mix.inspect if not mix.nil?
      log.ap ex.backtrace
      return false
    end

    log.info "[add_remix] updating mix textual info."
    info_to_update = @vid_service.new_mix()
    update_mix_textual_info(info_to_update, project)

    begin
      log.info "[add_remix] updating mix to remote service."
      mix = @vid_service.update_mix(mix.id, info_to_update, username)
    rescue => ex
      log.error "[add_remix] failed to update mix. Reason:"
      log.error ex.message
      log.error mix.inspect if not mix.nil?
      log.ap ex.backtrace
      return false
    end

    log.info "[add_remix] updating project video info."
    update_project_video_info(project, mix)

    log.info "[add_remix] fetching video entries used in mix from remote service."
    begin
      entries = @vid_service.all_video_entries_used_in_mix(mix.id, username)
    rescue => ex
      log.error "[add_remix] failed to fetch entries used in mix. Reason:"
      log.error ex.message
      log.error mix.inspect if not mix.nil?
      log.ap ex.backtrace
      return false
    end

    log.info "[add_remix] updating project clips info, incl updating clips in db."
    update_project_clips_info(project, entries, project.user.id)

    log.info "[add_remix] done."
    true
  end

  def add_mix(project)
    log = project.logger

    log.info "[add_mix] creating new mix object."
    mix = @vid_service.new_mix()
    update_mix_textual_info(mix, project)

    begin
      log.info "[add_mix] adding mix to remote service."
      mix = @vid_service.add_mix(mix, project.user.username)
    rescue => ex
      log.error "[add_mix] failed to add mix. Reason:"
      log.error ex.message
      log.error mix.inspect
      log.ap ex.backtrace
      return false
    end

    log.info "[add_mix] updating project video info."
    update_project_video_info(project, mix)

    log.info "[add_mix] done."
    true
  end

  
  def update_project_video_info(project, mix)
    project.thumbnail_url = mix.thumbnail_url
    project.video_id = mix.id
    project.duration = mix.duration
  end

  def update_mix_textual_info(mix, project)
    mix.name = project.title
    mix.description = project.description
    mix.tags = project.tags
    #mix.categories = project.topic_codes_to_s
    mix.editor_type = @vid_service.editor_type_code(project.editor_type)
  end

  def update_project_clips_info(project, entries, db_user_id, log=nil)
    log ||= project.logger

    project.clips.clear # delete all

    log.info "\t total entries used in mix: #{ entries.size() }."
    entries.each do |entry|
      clip = Clip.find_by_video_id(entry.id) || Clip.new

      clip.user_id = db_user_id if clip.user_id.nil?

      update_clip_info(clip, entry)

      log.info "\t saving clip: #{ clip.video_id }, and add to project."
      clip.save

      project.clips << clip unless project.clips.include?(clip)
    end

    log.info "\t total clips used in project #{ project.clips.size() }."
    log.error "\t something wrong, total clips & entries shld be same!" if entries.size() != project.clips.size()
  end

  def update_clip_info(clip, entry)
    clip.title = entry.name
    clip.description = entry.description
    clip.tags = entry.tags
    # clip.topics = to_topic_array(clip.categories)

    clip.duration = entry.duration
    clip.video_id = entry.id
    clip.thumbnail_url = entry.thumbnail_url
  end

  def update_project_kse_uiconf(project)
    project.logger.info("[update-uiconf] start update KSE uiconf")
    project.uiconf_kcw_id ||= build_kcw_id(project.id, project.user.id)
    project.uiconf_kse_id ||= build_kse_id(project.uiconf_kcw_id, project.user.id)
  end

  def update_project_kae_uiconf(project)
    project.logger.info("[update-uiconf] start update KAE uiconf")
    project.uiconf_kcw_id ||= build_kcw_id(project.id, project.user.id)
    project.uiconf_kae_id ||= build_kae_id(project.uiconf_kcw_id, project.user.id)
  end

  def build_kcw_id(project_id, user_id)
    url = @search_url_builder.call(project_id, user_id)
    puts "\t[kcw] kcw url: #{ url }"
    kcw_uiconf = @vid_service.new_kcw_uiconf(url)

    kcw_uiconf = @vid_service.add_uiconf(kcw_uiconf, user_id)
    puts "\t[kcw] created: id:#{ kcw_uiconf }"

    kcw_uiconf.id
  end

  def build_kse_id(kcw_id, user_id)
    puts "\t[kse] use kcw: id:#{ kcw_id }"
    uc = @vid_service.new_kse_uiconf(kcw_id)
    uc = @vid_service.add_uiconf(uc, user_id)

    puts "\t[kse] created: id: #{ uc.id }"
    uc.id
  end

  def build_kae_id(kcw_id, user_id)
    puts "\t[kae] use kcw: id:#{ kcw_id }"
    uc = @vid_service.new_kae_uiconf(kcw_id)
    uc = @vid_service.add_uiconf(uc, user_id)

    puts "\t[kae] created: id: #{ uc.id }"
    uc.id
  end

end


######
require 'kaltura'

class KalturaVideoService

  def initialize(kaltura_cfg)
    @cfg = kaltura_cfg
  end

  # Creates a new Mix entry
  def new_mix()
    Kaltura::MixEntry.new
  end

  # Add Mix entry to Kaltura Server.
  # Returns Mix entry with updated info when created successfully.
  def add_mix(mix, user_id)
    admin_client(user_id).mixing_service.add(mix)
  end

  def get_mix(video_id, user_id)
    admin_client(user_id).mixing_service.get(video_id)
  end

  def clone_mix(video_id, user_id)
    admin_client(user_id).mixing_service.clone(video_id)
  end

  def update_mix(mix_id, info_to_update, user_id)
    admin_client(user_id).mixing_service.update(mix_id, info_to_update)
  end

  def all_video_entries_used_in_mix(mix_id, user_id)
    entries = admin_client(user_id).mixing_service.get_ready_media_entries(mix_id) || []
    entries.select { |entry| entry.media_type == Kaltura::Constants::Media::Type::VIDEO }
  end

  def append_entry_to_mix(mix_id, entry_id, user_id)
    admin_client(user_id).mixing_service.append_media_entry(mix_id, entry_id)
  end

  # Returns Kaltura's editor type code for "basic" and "advanced"
  def editor_type_code(editor_type)
    case editor_type
      when "basic"    then Kaltura::Constants::EditorType::SIMPLE
      when "advanced" then Kaltura::Constants::EditorType::ADVANCED
      else raise ArgumentError,
           "Invalid editor_type: #{ editor_type } (valid: ['basic', 'advanced'])"
    end
  end

  def admin_client(user_id)
    client(admin_session(user_id))
  end

  def client(session=nil)
    config = Kaltura::Configuration.new(@cfg.partner_id)
    client = Kaltura::Client.new(config)
    client.ks = session

    client
  end

  def admin_session(user_id)
    client().session_service.start(@cfg.admin_secret, user_id,
                Kaltura::Constants::SessionType::ADMIN)
  end

  def add_uiconf(uiconf, user_id)
    admin_client(user_id).ui_conf_service.add(uiconf)
  end


  
  def new_kse_uiconf(kcw_uiconf_id)
    uc = Kaltura::UiConf.new
    uc.name = "Custom KSE that uses KCW(id: #{ kcw_uiconf_id })"
    uc.swf_url = "/flash/kse/v2.3.3/simpleeditor.swf"
    uc.obj_type = Kaltura::Constants::UiConf::ObjType::SIMPLE_EDITOR
    uc.creation_mode = Kaltura::Constants::UiConf::CreationMode::ADVANCED
    uc.use_cdn = true
    uc.conf_file = <<CONTENT
<SimpleEditor>

	<ContributionWizard>
		<UIConfigId>#{ kcw_uiconf_id }</UIConfigId>
	</ContributionWizard>
	<Welcome>/content/uiconf/kaltura/generic/kse_2.3.2/kaltura_welcome.swf</Welcome>

	<DefaultTransition>None</DefaultTransition>
	<enableCW>true</enableCW>

	<KPaint>
		<target>/flash/kpaint/v1.0.4/Painter.swf</target>
		<shapes>/flash/kpaint/v1.0.1/shapes</shapes>
		<fonts>/flash/kpaint/v1.0.1/fonts</fonts>
		<config>/flash/kpaint/v1.0.1/kpaint_config.xml</config>
	</KPaint>

	<UIConfigList>
    	<UIConfig>
			<target>simpleeditor.swf</target>
		    <cssUrl>/content/uiconf/kaltura/generic/kse_2.3.2/styles_kse_light.swf</cssUrl>
		    <localeUrl>/content/uiconf/kaltura/generic/kse_2.3.1/en_us_SimpleEditor.swf</localeUrl>
		</UIConfig>
	</UIConfigList>

</SimpleEditor>

CONTENT

    uc
  end

  
  def new_kae_uiconf(kcw_uiconf_id)
    uc = Kaltura::UiConf.new
    uc.name = "Custom KAE that uses KCW(id: #{ kcw_uiconf_id })"
    uc.swf_url = "/flash/kae/v1.2.3/KalturaAdvancedVideoEditor.swf"
    uc.obj_type = Kaltura::Constants::UiConf::ObjType::ADVANCED_EDITOR
    uc.creation_mode = Kaltura::Constants::UiConf::CreationMode::ADVANCED
    uc.use_cdn = true
    uc.conf_file = <<CONTENT
<uiConf version="1.0.8_trunk"><overrides>
		<mediaClips>
			<librarySort>
				<clipsVisual visible="0"><sortBy>
					<type>number</type>
					<field>duration</field>
					<showName>CLIP LENGTH</showName></sortBy><sortBy>
					<type>number</type>
					<field>createdAtAsInt</field>
					<showName>CREATION DATE</showName></sortBy><sortBy>
					<type>string</type>
					<field>entryName</field>
					<showName>CLIP NAME</showName></sortBy></clipsVisual>
				<clipsAudio visible="0"><sortBy>
					<type>number</type>
					<field>duration</field>
					<showName>CLIP LENGTH</showName></sortBy><sortBy>
					<type>number</type>
					<field>createdAtAsInt</field>
					<showName>CREATION DATE</showName></sortBy><sortBy>
					<type>string</type>
					<field>entryName</field>
					<showName>CLIP NAME</showName></sortBy></clipsAudio></librarySort>
			<libraryFilter>
				<clipsVisual visible="1">
				<filterBy>
					<type>none</type>
					<showName>View All</showName></filterBy><filterBy>
					<field>mediaType</field>
					<value>2</value>
					<type>mediaType</type>
					<showName>Video Only</showName></filterBy><filterBy>
					<field>mediaType</field>
					<value>4</value>
					<type>mediaType</type>
					<showName>Photos Only</showName></filterBy></clipsVisual>
				<clipsAudio visible="0"><filterBy>
					<type>none</type>
					<showName>SHOW ALL</showName></filterBy><filterBy>
					<field>adminTags</field>
					<value>music</value>
					<type>tags</type>
					<showName>MUSIC</showName></filterBy><filterBy>
					<field>tags</field>
					<value>voice</value>
					<type>tags</type>
					<showName>RECORDINGS</showName></filterBy>
					<filterBy>
						<field>adminTags</field>
						<value>sound effects</value>
						<type>tags</type>
						<showName>SOUND FX</showName></filterBy></clipsAudio></libraryFilter>
			<mediaTypes>
				<mediaType>
					<typeId>SOLID</typeId>
					<defaultColor>#00f00f</defaultColor>
					<defaultDuration>2</defaultDuration>
					<showInMediaClips>1</showInMediaClips>
					</mediaType>
				<mediaType>
					<typeId>SILENCE</typeId>
					<defaultDuration>2</defaultDuration>
					<showInMediaClips>1</showInMediaClips>
				</mediaType>
				<mediaType>
					<typeId>TRANSITION</typeId><defaultTransitionId>None</defaultTransitionId><defaultDuration>2</defaultDuration><transitionsClearRoughcut>0</transitionsClearRoughcut>
					<defaultTransitionCross>0</defaultTransitionCross></mediaType><mediaType>
					<typeId>IMAGE</typeId>
					<defaultDuration>4</defaultDuration>
					</mediaType>
				<defaultMaxStaticTypesDuration>30</defaultMaxStaticTypesDuration>
				<defaultMinStaticTypesDuration>0.25</defaultMinStaticTypesDuration><defaultMinStreamingTypesDuration>0.25</defaultMinStreamingTypesDuration>
				</mediaTypes></mediaClips>
		<uiElements>
			<removeElements></removeElements></uiElements>
		<publishSettings>


			<postPublishWindow show="1"><showPostPublishAlert>0</showPostPublishAlert>
				<thumbnailSettings><width>640</width><height>480</height><quality>90</quality></thumbnailSettings></postPublishWindow></publishSettings></overrides><uIConfigList>
		<uIConfig>
			<cvf>
				<pluginsDirectory>/flash/kae/v1.2/swf/plugins/cvesdk</pluginsDirectory>
				<mediaServerUrl>rtmp://{DOMAIN_NAME}/oflaDemo</mediaServerUrl>
				<pluginsProvider>/flash/kae/v1.2/swf/plugins/cvesdk/plugins.xml</pluginsProvider></cvf>
			<target>KalturaAdvancedVideoEditor.swf</target>
			<cssUrl>/content/uiconf/kaltura/generic/kae_1.2/kae_generic_generic_styles.swf?r=2</cssUrl>
			<localeUrl>/content/uiconf/kaltura/generic/kae_1.2/en_US_KalturaAdvancedVideoEditor.swf?r=0</localeUrl>
			<baseLocaleUrl>/content/uiconf/kaltura/generic/kae_1.2/kae_generic_en_US.swf?r=0</baseLocaleUrl></uIConfig>
	</uIConfigList><extraData>
		<contributionWizard>
			<uIConfigId>#{ kcw_uiconf_id }</uIConfigId>
		</contributionWizard>
	</extraData><screens>
		<helpWindowUrl>/content/uiconf/kaltura/generic/kae_1.2/KAE_Help.png</helpWindowUrl></screens><javaScript enableJSCallbacks="1" enableStatisticsCallbacks="1" enableErrorCallbacks="1" verbose="0">
		<jsBlock >
			<blockId>publishHandler</blockId><jsHandler>afterPublishHandler</jsHandler><jsfunction></jsfunction><!--a function to call the container when the user published the roughcut or clicked the close button to nabigate away from the editor. the function get an object with 3 params, first (modified) indicates if there was a change to the roughcut, the second (saved) indicates if the user saved the last changes he made or not.-->
		</jsBlock>
	<jsBlock>
			<blockId>closeHandler</blockId><jsHandler>closeEditorHandler</jsHandler><jsfunction></jsfunction><!--a function to call the container when the user chosed to exit the editor (clicked the close button to navigate away from the editor)-->
		</jsBlock></javaScript>
	<notificationsAndRequests>
		<enableStatisticsRequests>1</enableStatisticsRequests>
		<enableReportErrorsRequests>1</enableReportErrorsRequests></notificationsAndRequests></uiConf>
CONTENT

    uc
  end

  def new_kcw_uiconf(search_url)
    uc = Kaltura::UiConf.new
    uc.name = "Stroome KCW"
    uc.obj_type = Kaltura::Constants::UiConf::ObjType::CONTRIBUTION_WIZARD
    uc.creation_mode = Kaltura::Constants::UiConf::CreationMode::WIZARD
    uc.swf_url = "/flash/kcw/v2.1.6.3/ContributionWizard.swf"
    uc.use_cdn = true
    uc.conf_file = <<CONTENT
<kcw>
  <UIConfigList>
    <UIConfig>
      <target>ContributionWizard.swf</target>
      <cssUrl>/content/uiconf/kaltura/generic/kcw_2.1.5/style/style.swf</cssUrl>
      <localeUrl>/content/uiconf/kaltura/kmc/kcw/v2.1.5/en_US_ContributionWizard_kaltura.swf</localeUrl>
    </UIConfig>
  </UIConfigList>
  <ImportTypesConfig>
    <taggingConfig>
      <minTitleLen>1</minTitleLen>
      <maxTitleLen>2000</maxTitleLen>
      <minTagsLen>0</minTagsLen>
      <maxTagsLen>2000</maxTagsLen>
    </taggingConfig>
  </ImportTypesConfig>
  <webcamParams>
    <keyFrameInterval/>
    <width/>
    <height/>
    <framerate/>
    <favorArea/>
    <bandwidth/>
    <quality/>
  </webcamParams>
  <limitations>
    <upload>
      <singleFileSize min="-1" max="-1"/>
      <numFiles min="-1" max="100"/>
      <totalFileSize min="-1" max="-1"/>
    </upload>
    <search>
      <numFiles min="-1" max="-1"/>
    </search>
  </limitations>
  <mediaTypes>
    <media type="video">

      <provider id="thissite" name="thissite" code="28">
        <moduleUrl>SearchView.swf</moduleUrl>
        <authMethodList>
          <authMethod type="1"/>
        </authMethodList>
        <tokens>
          <token>
            <name>extra_data</name>
            <value>#{ search_url }</value>
          </token>
        </tokens>
      </provider>

	    <provider id="upload" name="upload" code="1">
        <authMethodList>
          <authMethod type="1"/>
        </authMethodList>
        <moduleUrl>UploadView.swf</moduleUrl>
        <fileFilters>
          <filter type="video">
            <allowedTypes>flv,asf,qt,mov,mpg,avi,wmv,mp4,3gp,f4v,m4v</allowedTypes>
          </filter>
        </fileFilters>
      </provider>

      <provider id="webcam" name="webcam" code="2">
        <authMethodList>
          <authMethod type="1"/>
        </authMethodList>
        <moduleUrl>WebcamView.swf</moduleUrl>
        <customData>
          <serverUrl>rtmp://{HOST_NAME}/oflaDemo</serverUrl>
        </customData>
      </provider>

      <provider id="metacafe" name="metacafe" code="24">
        <moduleUrl>SearchView.swf</moduleUrl>
        <authMethodList>
          <authMethod type="1"/>
        </authMethodList>
      </provider>

     </media>

    <media type="audio">
      <provider id="thissite" name="thissite" code="28">
        <moduleUrl>SearchView.swf</moduleUrl>
        <authMethodList>
          <authMethod type="1"/>
        </authMethodList>
        <tokens>
          <token>
            <name>extra_data</name>
            <value>#{ search_url }</value>
          </token>
        </tokens>
      </provider>

      <provider id="upload" name="upload" code="1">
        <authMethodList>
          <authMethod type="1"/>
        </authMethodList>
        <moduleUrl>UploadView.swf</moduleUrl>
        <fileFilters>
          <filter type="audio">
            <allowedTypes>flv,asf,wmv,qt,mov,mpg,avi,mp3,wav</allowedTypes>
          </filter>
        </fileFilters>
      </provider>

      <provider id="ccmixter" name="ccmixter" code="10">
        <moduleUrl>SearchView.swf</moduleUrl>
        <authMethodList>
          <authMethod type="1"/>
          <authMethod type="3"/>
        </authMethodList>
      </provider>

      <provider id="jamendo" name="jamendo" code="9">
        <moduleUrl>SearchView.swf</moduleUrl>
        <authMethodList>
          <authMethod type="1"/>
          <authMethod type="3"/>
        </authMethodList>
      </provider>
    </media>

    <media type="image">

      <provider id="thissite" name="thissite" code="28">
        <moduleUrl>SearchView.swf</moduleUrl>
        <authMethodList>
          <authMethod type="1"/>
        </authMethodList>
        <tokens>
          <token>
            <name>extra_data</name>
            <value>#{ search_url }</value>
          </token>
        </tokens>
      </provider>

      <provider id="upload" name="upload" code="1">
        <authMethodList>
          <authMethod type="1"/>
        </authMethodList>
        <moduleUrl>UploadView.swf</moduleUrl>
        <fileFilters>
          <filter type="image">
            <allowedTypes>jpg,bmp,png,gif,tiff</allowedTypes>
          </filter>
        </fileFilters>
      </provider>

      <provider id="flickr" name="flickr" code="3">
        <moduleUrl>SearchView.swf</moduleUrl>
        <authMethodList>
          <authMethod type="1"/>
          <authMethod type="4" searchable="false"/>
        </authMethodList>
      </provider>

      <provider id="nypl" name="nypl" code="11">
        <moduleUrl>SearchView.swf</moduleUrl>
        <authMethodList>
          <authMethod type="1"/>
        </authMethodList>
      </provider>
    </media>
  </mediaTypes>
  <StartupDefaults>
    <SingleContribution>false</SingleContribution>
    <autoTOUConfirmation>true</autoTOUConfirmation>
    <showLogoImage>false</showLogoImage>
    <NavigationProperties>
      <showCloseButton>true</showCloseButton>
      <enableIntroScreen>false</enableIntroScreen>
      <enableTagging>true</enableTagging>
    </NavigationProperties>
    <gotoScreen>
      <mediaType>video</mediaType>
      <mediaProviderName>thissite</mediaProviderName>
    </gotoScreen>
  </StartupDefaults>
</kcw>

CONTENT

    uc
  end
end

