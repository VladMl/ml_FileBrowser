set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_050000 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2013.01.01'
,p_release=>'5.0.3.00.03'
,p_default_workspace_id=>1662411001039280
,p_default_application_id=>113
,p_default_owner=>'APEX_PLUGIN'
);
end;
/
prompt --application/ui_types
begin
null;
end;
/
prompt --application/shared_components/plugins/region_type/ml_filebrowser
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(13100170219520985)
,p_plugin_type=>'REGION TYPE'
,p_name=>'ML_FILEBROWSER'
,p_display_name=>'ml_FileBrowser'
,p_supported_ui_types=>'DESKTOP'
,p_image_prefix=>'#IMAGE_PREFIX#plugins/com.ml.filebrowser/'
,p_javascript_file_urls=>'#IMAGE_PREFIX#plugins/com.ml.filebrowser/ml_FileBrowser.js'
,p_plsql_code=>wwv_flow_utilities.join(wwv_flow_t_varchar2(
'function render ',
'(',
'    p_region                in  apex_plugin.t_region,',
'    p_plugin                in  apex_plugin.t_plugin,',
'    p_is_printer_friendly   in  boolean ',
')',
'return apex_plugin.t_region_render_result',
'is',
'  l_directory                varchar2(400)           := p_region.attribute_01;',
'  l_schema varchar2(100);',
'begin',
'',
'select sys_context(''userenv'',''current_schema'') into l_schema from dual;',
'',
'htp.p(''<script> ',
'        var imgPath = "#APP_IMAGES#";',
'        var rootPath = "'' || p_region.attribute_01 ||''";',
'        var schema = "'' || l_schema ||''";',
'      </script>'');',
'',
' ',
'',
'',
'',
' htp.p(''<div id="ml-filebrowser-breadcrumb-region" class="t-BreadcrumbRegion t-BreadcrumbRegion--showBreadcrumb t-BreadcrumbRegion--useBreadcrumbTitle">''); ',
'',
' htp.p(''<div class="t-BreadcrumbRegion-body">'');',
' htp.p(''<div class="t-BreadcrumbRegion-breadcrumb" id="ml-filebrowser-breadcrumb">'');',
' ',
'',
'  htp.p(''</div>'');',
'  htp.p(''</div>'');',
'  htp.p(''</div>'');',
'  ',
' htp.p(''<div class="t-Region-body" id="ml-files">'');',
'     ',
'      ',
'      ',
'',
'   htp.p(''</div>'');',
'',
'',
'   htp.p(''<script>',
'         document.addEventListener("DOMContentLoaded", function(event) { ',
'        ',
'            getFiles("''|| p_region.attribute_01  ||''");',
'         });',
'         </script>'');',
'',
' return null;',
'end;'))
,p_render_function=>'render'
,p_ajax_function=>'getFiles'
,p_standard_attributes=>'SOURCE_SQL:SOURCE_REQUIRED'
,p_sql_min_column_count=>1
,p_substitute_attributes=>false
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_files_version=>2
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(13102294289359927)
,p_plugin_id=>wwv_flow_api.id(13100170219520985)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Directory'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '616C65727428276666666627293B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(13244299167474477)
,p_plugin_id=>wwv_flow_api.id(13100170219520985)
,p_file_name=>'ml_FileBrowser.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
