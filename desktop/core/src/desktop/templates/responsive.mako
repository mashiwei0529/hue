## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
  from desktop import conf
  from desktop.views import _ko
  from django.utils.translation import ugettext as _
  from desktop.lib.i18n import smart_unicode
  from desktop.views import login_modal
  from metadata.conf import has_optimizer, OPTIMIZER
%>

<%namespace name="koComponents" file="/ko_components.mako" />
<%namespace name="assist" file="/assist.mako" />
<%namespace name="hueIcons" file="/hue_icons.mako" />
<%namespace name="commonHeaderFooterComponents" file="/common_header_footer_components.mako" />

<!DOCTYPE html>
<html lang="en" dir="ltr">
<head>
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta charset="utf-8">
  <title>Hue</title>
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <link rel="icon" type="image/x-icon" href="${ static('desktop/art/favicon.ico') }"/>
  <meta name="description" content="">
  <meta name="author" content="">

  <link href="${ static('desktop/ext/css/bootplus.css') }" rel="stylesheet">
  <link href="${ static('desktop/css/hue3.css') }" rel="stylesheet">
  <link href="${ static('desktop/ext/css/font-awesome.min.css') }" rel="stylesheet">
  <link href="${ static('desktop/css/responsive.css') }" rel="stylesheet">
  <link href="${ static('desktop/css/jquery-ui.css') }" rel="stylesheet">

  ${ commonHeaderFooterComponents.header_i18n_redirection(user, is_s3_enabled, apps) }

</head>

<body>

% if is_demo:
  <ul class="side-labels unstyled">
    <li class="feedback"><a href="javascript:showClassicWidget()"><i class="fa fa-envelope-o"></i> ${_('Feedback')}</a></li>
  </ul>

  <!-- UserVoice JavaScript SDK -->
  <script>(function(){var uv=document.createElement('script');uv.type='text/javascript';uv.async=true;uv.src='//widget.uservoice.com/8YpsDfIl1Y2sNdONoLXhrg.js';var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(uv,s)})()</script>
  <script>
  UserVoice = window.UserVoice || [];
  function showClassicWidget() {
    UserVoice.push(['showLightbox', 'classic_widget', {
      mode: 'feedback',
      primary_color: '#338cb8',
      link_color: '#338cb8',
      forum_id: 247008
    }]);
  }
  </script>
% endif

<div id="jHueNotify" class="alert hide">
    <button class="close">&times;</button>
    <div class="message"></div>
</div>


${ hueIcons.symbols() }

<div class="main-page">
  <div class="top-nav">
    <div class="top-nav-left">
      <a class="hamburger hamburger-hue pull-left" type="button" data-bind="toggle: leftNavVisible, css: { 'is-active': leftNavVisible }">
      <span class="hamburger-box">
        <span class="hamburger-inner"></span>
      </span>
      </a>
      <a class="nav-tooltip pull-left" title="${_('Homepage')}" rel="navigator-tooltip"  href="#" data-bind="click: function(){ onePageViewModel.currentApp('home') }">
        <svg style="margin-top:12px;margin-left:8px;height: 24px;width:120px;display: inline-block;">
          <use xlink:href="#hue-logo"></use>
        </svg>
      </a>
      <div class="compose-action btn-group">
        <button class="btn" data-bind="click: function(){ onePageViewModel.changeEditorType('hive'); onePageViewModel.currentApp('editor') }" title="${ _('Open editor') }">${ _('Compose') }</button>
        <button class="btn dropdown-toggle" data-toggle="dropdown">
          <span class="caret"></span>
        </button>

        <ul class="dropdown-menu">
          % if 'beeswax' in apps and 'impala' in apps:
            <li class="dropdown-submenu">
              <a title="${_('Query editor')}" rel="navigator-tooltip" href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.changeEditorType('hive'); onePageViewModel.currentApp('editor') }"><i class="fa fa-fw fa-edit inline-block"></i> ${ _('Query') }</a>
              <ul class="dropdown-menu">
                <li><a href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.changeEditorType('hive'); onePageViewModel.currentApp('editor') }"><img src="${ static(apps['beeswax'].icon_path) }" class="app-icon"/> ${_('Hive Query')}</a></li>
                <li><a href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.changeEditorType('impala'); onePageViewModel.currentApp('editor') }"><img src="${ static(apps['impala'].icon_path) }" class="app-icon"/> ${_('Impala Query')}</a></li>
              </ul>
            </li>
          % endif
          % if 'beeswax' in apps and 'impala' not in apps:
            <li><a href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.changeEditorType('hive'); onePageViewModel.currentApp('editor') }"><img src="${ static(apps['beeswax'].icon_path) }" class="app-icon"/> ${_('Hive Query')}</a></li>
          % endif
          % if 'impala' in apps and 'beeswax' not in apps: ## impala requires beeswax anyway
            <li><a href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.changeEditorType('impala'); onePageViewModel.currentApp('editor') }"><img src="${ static(apps['impala'].icon_path) }" class="app-icon"/> ${_('Impala Query')}</a></li>
          % endif
          % if 'search' in apps:
            <li><a href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.currentApp('search') }"><i class="fa fa-fw fa-area-chart"></i> ${ _('Dashboard') }</a></li>
          % endif
          <li><a href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.currentApp('notebook') }"><i class="fa fa-fw fa-file-text-o inline-block"></i> ${ _('Report') }</a></li>
          % if 'oozie' in apps:
          % if not user.has_hue_permission(action="disable_editor_access", app="oozie") or user.is_superuser:
            <li class="dropdown-submenu">
              <a title="${_('Schedule with Oozie')}" rel="navigator-tooltip" href="#"><img src="${ static('oozie/art/icon_oozie_editor_48.png') }" class="app-icon" /> ${ _('Workflow') }</a>
              <ul class="dropdown-menu">
                <li><a href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.currentApp('oozie_workflow') }"><img src="${ static('oozie/art/icon_oozie_workflow_48.png') }" class="app-icon"/> ${_('Workflow')}</a></li>
                <li><a href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.currentApp('oozie_coordinator') }"><img src="${ static('oozie/art/icon_oozie_coordinator_48.png') }" class="app-icon" /> ${_('Schedule')}</a></li>
                <li><a href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.currentApp('oozie_bundle') }"/><img src="${ static('oozie/art/icon_oozie_bundle_48.png') }" class="app-icon" /> ${_('Bundle')}</a></li>
              </ul>
            </li>
          % endif
          % endif
          % if len(interpreters) > 0:
          <li class="divider"></li>
          <li class="dropdown-submenu">
            <a title="${_('More...')}" rel="navigator-tooltip" href="#"><span class="dropdown-no-icon">${ _('More') }</span></a>
            <ul class="dropdown-menu">
              % for interpreter in interpreters:
                % if interpreter['name'] != 'Hive' and interpreter['name'] != 'Impala':
                <li><a  href="javascript: void(0)" data-bind="click: function(){ onePageViewModel.changeEditorType('${ interpreter['type'] }'); onePageViewModel.currentApp('editor') }"><span class="dropdown-no-icon">${ interpreter['name'] }</span></a></li>
                % endif
              % endfor
              % if user.is_superuser:
                <li class="divider"></li>
                <li><a href="gethue.com" class="dropdown-no-icon">${ _('Add more...') }</a></li>
              % endif
            </ul>
          </li>
          % endif
        </ul>
      </div>
    </div>
    <div class="top-nav-middle">
      <div class="search-container">
        <input placeholder="${ _('Search all data and saved documents...') }" type="text"
          data-bind="autocomplete: {
              source: searchAutocompleteSource,
              itemTemplate: 'nav-search-autocomp-item',
              noMatchTemplate: 'nav-search-autocomp-no-match',
              classPrefix: 'nav-',
              showOnFocus: true,
              onEnter: performSearch,
              reopenPattern: /.*:$/
            },
            hasFocus: searchHasFocus,
            clearable: { value: searchInput, onClear: function () { searchActive(false); huePubSub.publish('autocomplete.close'); } },
            textInput: searchInput,
            valueUpdate: 'afterkeydown'"
        >
        <a class="inactive-action" data-bind="click: performSearch"><i class="fa fa-search" data-bind="css: { 'blue': searchHasFocus() || searchActive() }"></i></a>
      </div>
    </div>
    <div class="top-nav-right">
      % if user.is_authenticated() and section != 'login':
        <div class="compose-action btn-group">
          <%
            view_profile = user.has_hue_permission(action="access_view:useradmin:edit_user", app="useradmin") or user.is_superuser
          %>
          <button class="btn"
          % if view_profile:
            ### <a href="${ url('useradmin.views.edit_user', username=user.username) }"
            data-bind="click: function(){ onePageViewModel.currentApp('jobbrowser') }" title="${ _('View Profile') if is_ldap_setup else _('Edit Profile') }"
          % endif
          >
          ${ user.username }
          </button>
          % if user.is_superuser:
            <button class="btn dropdown-toggle" data-toggle="dropdown">
              <span class="caret"></span>
            </button>
            <ul class="dropdown-menu" >
              <li><a href="${ url('useradmin.views.list_users') }"><i class="fa fa-group"></i> ${_('Manage Users')}</a></li>
              <li><a href="${ url('useradmin.views.list_permissions') }"><i class="fa fa-key"></i> ${_('Set Permissions')}</a></li>
              <li><a href="/about"><span class="dropdown-no-icon">${_('Help')}</span></a></li>
              <li><a href="/about"><span class="dropdown-no-icon">${_('About Hue')}</span></a></li>
              <li class="divider"></li>
              <li><a title="${_('Sign out')}" href="/accounts/logout/"><i class="fa fa-sign-out"></i> ${ _('Sign out') }</a></li>
            </ul>
          % endif
        </div>

        <div class="compose-action btn-group">
          <button class="btn" title="${_('Submission history')}" data-bind="toggle: historyPanelVisible"><i class="fa fa-history"></i>  <div class="jobs-badge">20</div></button>
        </div>
        <div class="jobs-panel" data-bind="visible: historyPanelVisible" style="display: none;">
          <span style="font-size: 15px; font-weight: 300">${_('Workflows')} (20)</span>
        </div>

        <div class="compose-action btn-group">
          <button class="btn" title="${_('Running jobs and workflows')}" data-bind="click: function(){ onePageViewModel.currentApp('jobbrowser') }">${ _('Jobs') } </button>
          <button class="btn dropdown-toggle" data-bind="toggle: jobsPanelVisible">
            <span class="caret"></span>
          </button>
        </div>
        <div class="jobs-panel" data-bind="visible: jobsPanelVisible" style="display: none;">
          <span style="font-size: 15px; font-weight: 300">${_('Workflows')} (20)</span>
        </div>
      % endif
    </div>
  </div>

  <div class="content-wrapper">
    <div class="left-nav" data-bind="css: { 'left-nav-visible': leftNavVisible }, niceScroll">
      <ul class="left-nav-menu">
        <li class="header" style="padding-left: 4px; border-bottom: 1px solid #DDD; padding-bottom: 3px;">${ _('Applications') }</li>
        <li data-bind="click: function () { onePageViewModel.currentApp('home') }"><a href="javascript: void(0);">Home</a></li>
        <li data-bind="click: function () { onePageViewModel.changeEditorType('hive'); onePageViewModel.currentApp('editor') }"><a href="javascript: void(0);">Editor</a></li>
        <li data-bind="click: function () { onePageViewModel.currentApp('search') }"><a href="javascript: void(0);">Dashboard</a></li>
        <li data-bind="click: function () { onePageViewModel.currentApp('notebook') }"><a href="javascript: void(0);">Report</a></li>
        <li data-bind="click: function () { onePageViewModel.currentApp('oozie_workflow') }"><a href="javascript: void(0);">Workflows</a></li>
        <li><a href="javascript: void(0);">Custom App 1</a></li>
        <li><a href="javascript: void(0);">Custom App 2</a></li>
        <li><a href="javascript: void(0);">Custom App 3</a></li>
        <li class="header">&nbsp;</li>
        <li class="header" style="padding-left: 4px; border-bottom: 1px solid #DDD; padding-bottom: 3px;">${ _('Browse') }</li>
        <li data-bind="click: function () { onePageViewModel.currentApp('jobbrowser') }"><a href="javascript: void(0);">Jobs</a></li>
        <li data-bind="click: function () { onePageViewModel.currentApp('metastore') }"><a href="javascript: void(0);">Tables</a></li>
        <li data-bind="click: function () { onePageViewModel.currentApp('indexes') }"><a href="javascript: void(0);">Indexes</a></li>
        <li data-bind="click: function () { onePageViewModel.currentApp('filebrowser') }"><a href="javascript: void(0);">Files</a></li>
        <li data-bind="click: function () { onePageViewModel.currentApp('filebrowser_s3') }"><a href="javascript: void(0);">S3</a></li>
        <li><a href="javascript: void(0);">HBase</a></li>
        <li><a href="javascript: void(0);">Security</a></li>
      </ul>
      <div class="left-nav-drop">
        <div data-bind="click: function () { onePageViewModel.currentApp('importer') }" class="pointer" title="${ _('Import data wizard') }">
          <i class="fa fa-fw fa-cloud-upload"></i> ${ _('Drop files or click') }
        </div>
      </div>
    </div>

    <div class="left-panel" data-bind="css: { 'side-panel-closed': !leftAssistVisible() }, visibleOnHover: { selector: '.hide-left-side-panel' }">
      <a href="javascript:void(0);" style="z-index: 1000; display: none;" title="${_('Show Assist')}" class="pointer side-panel-toggle show-left-side-panel" data-bind="visible: ! leftAssistVisible(), toggle: leftAssistVisible"><i class="fa fa-chevron-right"></i></a>
      <a href="javascript:void(0);" style="display: none; opacity: 0;" title="${_('Hide Assist')}" class="pointer side-panel-toggle hide-left-side-panel" data-bind="visible: leftAssistVisible, toggle: leftAssistVisible"><i class="fa fa-chevron-left"></i></a>
      <!-- ko if: leftAssistVisible -->
      <div class="assist" data-bind="component: {
          name: 'assist-panel',
          params: {
            user: '${user.username}',
            sql: {
              sourceTypes: [{
                name: 'hive',
                type: 'hive'
              }],
              navigationSettings: {
                openItem: false,
                showStats: true
              }
            },
            visibleAssistPanels: ['sql']
          }
        }"></div>
      <!-- /ko -->
    </div>

    <div id="leftResizer" class="resizer" data-bind="visible: leftAssistVisible(), splitFlexDraggable : {
      containerSelector: '.content-wrapper',
      sidePanelSelector: '.left-panel',
      sidePanelVisible: leftAssistVisible,
      orientation: 'left',
      onPosition: function() { huePubSub.publish('split.draggable.position') }
    }"><div class="resize-bar">&nbsp;</div></div>


    <div class="page-content" data-bind="niceScroll: {horizrailenabled: false}">
      <!-- ko hueSpinner: { spin: isLoadingEmbeddable, center: true, size: 'xlarge' } --><!-- /ko -->
      <div id="embeddable_editor" class="embeddable"></div>
      <div id="embeddable_notebook" class="embeddable"></div>
      <div id="embeddable_metastore" class="embeddable"></div>
      <div id="embeddable_search" class="embeddable"></div>
      <div id="embeddable_oozie_workflow" class="embeddable"></div>
      <div id="embeddable_oozie_coordinator" class="embeddable"></div>
      <div id="embeddable_oozie_bundle" class="embeddable"></div>
      <div id="embeddable_jobbrowser" class="embeddable"></div>
      <div id="embeddable_filebrowser" class="embeddable"></div>
      <div id="embeddable_filebrowser_s3" class="embeddable"></div>
      <div id="embeddable_fileviewer" class="embeddable"></div>
      <div id="embeddable_home" class="embeddable"></div>
      <div id="embeddable_indexer" class="embeddable"></div>
      <div id="embeddable_importer" class="embeddable"></div>
      <div id="embeddable_collections" class="embeddable"></div>
      <div id="embeddable_indexes" class="embeddable"></div>
    </div>

    <div id="rightResizer" class="resizer" data-bind="visible: rightAssistVisible(), splitFlexDraggable : {
      containerSelector: '.content-wrapper',
      sidePanelSelector: '.right-panel',
      sidePanelVisible: rightAssistVisible,
      orientation: 'right',
      onPosition: function() { huePubSub.publish('split.draggable.position') }
    }"><div class="resize-bar" style="right: 0">&nbsp;</div></div>

    <div class="right-panel" data-bind="css: { 'side-panel-closed': !rightAssistVisible() }, visibleOnHover: { selector: '.hide-right-side-panel' }">
      <a href="javascript:void(0);" style="display: none;" title="${_('Show Assist')}" class="pointer side-panel-toggle show-right-side-panel" data-bind="visible: ! rightAssistVisible(), toggle: rightAssistVisible"><i class="fa fa-chevron-left"></i></a>
      <a href="javascript:void(0);" style="display: none; opacity: 0;" title="${_('Hide Assist')}" class="pointer side-panel-toggle hide-right-side-panel" data-bind="visible: rightAssistVisible, toggle: rightAssistVisible"><i class="fa fa-chevron-right"></i></a>

      <div data-bind="visible: rightAssistVisible" style="display: none; height: 100%; width: 100%; position: relative;">
        <ul class="right-panel-tabs nav nav-pills">
          <li data-bind="css: { 'active' : activeRightTab() === 'assistant' }"><a href="#functions" data-bind="click: function() { activeRightTab('assistant'); }">${ _('Assistant') }</a></li>
          <li data-bind="css: { 'active' : activeRightTab() === 'functions' }"><a href="#functions" data-bind="click: function() { activeRightTab('functions'); }">${ _('Functions') }</a></li>
          <li data-bind="css: { 'active' : activeRightTab() === 'schedules' }"><a href="#functions" data-bind="click: function() { activeRightTab('schedules'); }">${ _('Schedules') }</a></li>
        </ul>

        <div class="right-panel-tab-content tab-content">
          <!-- ko if: activeRightTab() === 'assistant' -->
          <div>Assistant</div>
          <!-- /ko -->

          <!-- ko if: activeRightTab() === 'functions' -->
          <div style="" data-bind="component: { name: 'functions-panel' }"></div>
          <!-- /ko -->

          <!-- ko if: activeRightTab() === 'schedules' -->
          <div>Schedules</div>
          <!-- /ko -->
        </div>
      </div>
    </div>
  </div>
</div>

<script src="${ static('desktop/ext/js/jquery/jquery-2.2.3.min.js') }"></script>
<script src="${ static('desktop/js/jquery.migration.js') }"></script>
<script src="${ static('desktop/js/hue.utils.js') }"></script>
<script src="${ static('desktop/ext/js/bootstrap.min.js') }"></script>
<script src="${ static('desktop/ext/js/bootstrap-better-typeahead.min.js') }"></script>
<script src="${ static('desktop/ext/js/fileuploader.js') }"></script>
<script src="${ static('desktop/ext/js/filesize.min.js') }"></script>
<script src="${ static('desktop/ext/js/moment-with-locales.min.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.total-storage.min.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.cookie.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.dataTables.1.8.2.min.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery.form.js') }"></script>
<script src="${ static('desktop/js/jquery.datatables.sorting.js') }"></script>

<script src="${ static('desktop/ext/js/jquery/plugins/jquery.basictable.min.js') }"></script>
<script src="${ static('desktop/ext/js/jquery/plugins/jquery-ui-1.10.4.custom.min.js') }"></script>

<script src="${ static('desktop/js/jquery.nicescroll.js') }"></script>

<script src="${ static('desktop/js/jquery.hiveautocomplete.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/js/jquery.hdfsautocomplete.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/js/jquery.filechooser.js') }"></script>
<script src="${ static('desktop/js/jquery.selector.js') }"></script>
<script src="${ static('desktop/js/jquery.delayedinput.js') }"></script>
<script src="${ static('desktop/js/jquery.rowselector.js') }"></script>
<script src="${ static('desktop/js/jquery.notify.js') }"></script>
<script src="${ static('desktop/js/jquery.titleupdater.js') }"></script>
<script src="${ static('desktop/js/jquery.horizontalscrollbar.js') }"></script>
<script src="${ static('desktop/js/jquery.tablescroller.js') }"></script>
<script src="${ static('desktop/js/jquery.tableextender.js') }"></script>
<script src="${ static('desktop/js/jquery.tableextender2.js') }"></script>

<script src="${ static('desktop/ext/js/knockout.min.js') }"></script>
<script src="${ static('desktop/js/apiHelper.js') }"></script>
<script src="${ static('desktop/js/ko.charts.js') }"></script>
<script src="${ static('desktop/ext/js/knockout-mapping.min.js') }"></script>
<script src="${ static('desktop/ext/js/knockout-sortable.min.js') }"></script>
<script src="${ static('desktop/ext/js/knockout.validation.min.js') }"></script>
<script src="${ static('desktop/js/ko.editable.js') }"></script>
<script src="${ static('desktop/js/ko.hue-bindings.js') }"></script>
<script src="${ static('desktop/js/jquery.scrollup.js') }"></script>
<script src="${ static('desktop/js/jquery.tour.js') }"></script>
<script src="${ static('desktop/js/sqlFunctions.js') }"></script>

<script type="text/javascript" charset="utf-8">
(function () {
    var proxiedKORegister = ko.components.register;
    var LOADED_COMPONENTS = [];
    ko.components.register = function () {
      if (LOADED_COMPONENTS.indexOf(arguments[0]) === -1) {
        LOADED_COMPONENTS.push(arguments[0]);
        return proxiedKORegister.apply(this, arguments);
      }
    };
  })();
</script>

${ koComponents.all() }

${ commonHeaderFooterComponents.header_pollers(user, is_s3_enabled, apps) }

${ assist.assistJSModels() }
${ assist.assistPanel() }

<iframe id="zoomDetectFrame" style="width: 250px; display: none" ></iframe>

<script type="text/javascript" charset="utf-8">
  (function () {
    var proxiedKORegister = ko.components.register;
    var LOADED_COMPONENTS = [];
    ko.components.register = function () {
      if (LOADED_COMPONENTS.indexOf(arguments[0]) === -1) {
        LOADED_COMPONENTS.push(arguments[0]);
        return proxiedKORegister.apply(this, arguments);
      }
    };
  })();

  $(document).ready(function () {
    var options = {
      user: '${ user.username }',
      i18n: {
        errorLoadingDatabases: "${ _('There was a problem loading the databases') }"
      }
    };

    var onePageViewModel = (function () {
      var LOADED_JS = [];
      var LOADED_CSS = [];

      $('script[src]').each(function(){
        LOADED_JS.push($(this).attr('src'));
      });

      $('link[href]').each(function(){
        LOADED_CSS.push($(this).attr('href'));
      });

      var OnePageViewModel = function () {
        var self = this;

        self.EMBEDDABLE_PAGE_URLS = {
          editor: '/notebook/editor_embeddable',
          notebook: '/notebook/notebook_embeddable',
          metastore: '/metastore/tables/?is_embeddable=true',
          search: '/search/embeddable/new_search',
          oozie_workflow: '/oozie/editor/workflow/new/?is_embeddable=true',
          oozie_coordinator: '/oozie/editor/coordinator/new/?is_embeddable=true',
          oozie_bundle: '/oozie/editor/bundle/new/?is_embeddable=true',
          jobbrowser: '/jobbrowser/apps?is_embeddable=true',
          filebrowser: '/filebrowser/?is_embeddable=true',
          filebrowser_s3: '/filebrowser/view=S3A://?is_embeddable=true',
          fileviewer: 'filebrowser/view=',
          home: '/home_embeddable',
          indexer: '/indexer/indexer/?is_embeddable=true',
          collections: '/search/admin/collections?is_embeddable=true',
          indexes: '/indexer/?is_embeddable=true',
          importer: '/indexer/importer/?is_embeddable=true',
        };

        self.SKIP_CACHE = ['fileviewer'];

        self.embeddable_cache = {};

        self.getActiveAppViewmodel = function () {
          var koElementID = '#' + self.currentApp() + 'Components';
          if ($(koElementID).length > 0 && ko.dataFor($(koElementID)[0])) {
            return ko.dataFor($(koElementID)[0]);
          }
          return null;
        }

        self.currentApp = ko.observable();
        self.isLoadingEmbeddable = ko.observable(false);

        self.extraEmbeddableURLParams = ko.observable('');

        self.changeEditorType = function (type) {
          self.extraEmbeddableURLParams('?type=' + type);
          hueUtils.changeURLParameter('type', type);
          var checkForEditor = window.setInterval(function(){
            if (self.getActiveAppViewmodel() && self.getActiveAppViewmodel().selectedNotebook && self.getActiveAppViewmodel().selectedNotebook()) {
              self.getActiveAppViewmodel().selectedNotebook().selectedSnippet(type);
              self.getActiveAppViewmodel().editorType(type);
              self.getActiveAppViewmodel().newNotebook();
              window.clearInterval(checkForEditor);
            }
          }, 100);
        }

        huePubSub.subscribe('open.fb.file', function (path) {
          self.extraEmbeddableURLParams(path + '?is_embeddable=true');
          hueUtils.changeURLParameter('path', path);
          self.currentApp('fileviewer');
        });

        huePubSub.subscribe('open.link', function (href) {
          if (href.startsWith('/notebook/editor')){
            if (location.getParameter('type') !== ''){
              if (hueUtils.getSearchParameter(href, 'type') !== '' && hueUtils.getSearchParameter(href, 'type') !== location.getParameter('type')) {
                self.changeEditorType(hueUtils.getSearchParameter(href, 'type'));
              }
            }
            else {
              if (hueUtils.getSearchParameter(href, 'type') !== ''){
                self.changeEditorType(hueUtils.getSearchParameter(href, 'type'));
              }
              else {
                self.changeEditorType('hive');
              }
              self.currentApp('editor')
            }
          }
          else if (href.startsWith('/notebook')){
            self.currentApp('notebook');
          }
          else if (href.startsWith('/pig')){
            self.changeEditorType('pig');
            self.currentApp('editor');
          }
          else if (href.startsWith('/search')){
            self.currentApp('search');
          }
          else if (href.startsWith('/oozie/editor/workflow/new')){
            self.currentApp('oozie_workflow');
          }
          else if (href.startsWith('/oozie/editor/coordinator/new')){
            self.currentApp('oozie_coordinator');
          }
          else if (href.startsWith('/oozie/editor/bundle/new')){
            self.currentApp('oozie_bundle');
          }
        });

        self.currentApp.subscribe(function (newVal) {
          hueUtils.changeURLParameter('app', newVal);
          if (newVal !== 'editor') {
            hueUtils.removeURLParameter('type');
          }
          self.isLoadingEmbeddable(true);
          if (typeof self.embeddable_cache[newVal] === 'undefined') {
            $.ajax({
              url: self.EMBEDDABLE_PAGE_URLS[newVal] + self.extraEmbeddableURLParams(),
              beforeSend: function (xhr) {
                xhr.setRequestHeader('X-Requested-With', 'Hue');
              },
              dataType: 'html',
              success: function (response) {
                self.extraEmbeddableURLParams('');
                var r = $(response);
                r.find('link').each(function () {
                  $(this).attr('href', $(this).attr('href') + '?' + Math.random())
                });
                // load just CSS and JS files that are not loaded before
                r.find('script[src]').each(function () {
                  var jsFile = $(this).attr('src').split('?')[0];
                  if (LOADED_JS.indexOf(jsFile) === -1) {
                    LOADED_JS.push(jsFile);
                    $(this).clone().appendTo($('head'));
                  }
                  $(this).remove();
                });
                r.find('link[href]').each(function () {
                  var cssFile = $(this).attr('href').split('?')[0];
                  if (LOADED_CSS.indexOf(cssFile) === -1) {
                    LOADED_CSS.push(cssFile);
                    $(this).clone().appendTo($('head'));
                  }
                  $(this).remove();
                });
                if (self.SKIP_CACHE.indexOf(newVal) === -1) {
                  self.embeddable_cache[newVal] = r;
                }
                $('#embeddable_' + newVal).html(r);
                self.isLoadingEmbeddable(false);
              }
            });
          } else {
            self.isLoadingEmbeddable(false);
          }
          $('.embeddable').hide();
          $('#embeddable_' + newVal).insertBefore($('.embeddable:first')).show();
        });

        if (window.location.getParameter('app') !== '' && self.EMBEDDABLE_PAGE_URLS[window.location.getParameter('app')]) {
          var app = window.location.getParameter('app');
          switch (app) {
            case 'fileviewer':
              if (window.location.getParameter('path') !== '') {
                self.extraEmbeddableURLParams(window.location.getParameter('path') + '?is_embeddable=true');
                self.currentApp(app);
              }
              else {
                self.currentApp('filebrowser');
              }
              break;
            case 'editor':
              if (window.location.getParameter('type') !== '') {
                self.changeEditorType(window.location.getParameter('type'));
              }
              self.currentApp(app);
              break;
            default:
              self.currentApp(app);
          }
        }
        else {
          self.currentApp('editor');
        }

        huePubSub.subscribe('switch.app', function (name) {
          self.currentApp(name);
        });

      };

      var onePageViewModel = new OnePageViewModel();
      ko.applyBindings(onePageViewModel, $('.page-content')[0]);
      return onePageViewModel;
    })();

    var sidePanelViewModel = (function () {
      function SidePanelViewModel () {
        var self = this;
        self.apiHelper = ApiHelper.getInstance();
        self.leftAssistVisible = ko.observable();
        self.rightAssistVisible = ko.observable();
        self.activeRightTab = ko.observable('functions');
        self.apiHelper.withTotalStorage('assist', 'left_assist_panel_visible', self.leftAssistVisible, true);
        self.apiHelper.withTotalStorage('assist', 'right_assist_panel_visible', self.rightAssistVisible, true);
      }

      var sidePanelViewModel = new SidePanelViewModel();
      ko.applyBindings(sidePanelViewModel, $('.left-panel')[0]);
      ko.applyBindings(sidePanelViewModel, $('#leftResizer')[0]);
      ko.applyBindings(sidePanelViewModel, $('#rightResizer')[0]);
      ko.applyBindings(sidePanelViewModel, $('.right-panel')[0]);
      return sidePanelViewModel;
    })();

    var topNavViewModel = (function (onePageViewModel) {
      function TopNavViewModel () {
        var self = this;
        self.onePageViewModel = onePageViewModel;
        self.leftNavVisible = ko.observable(false);

        self.onePageViewModel.currentApp.subscribe(function () {
          self.leftNavVisible(false);
        });

        self.apiHelper = ApiHelper.getInstance();
        self.searchActive = ko.observable(false);
        self.searchHasFocus = ko.observable(false);
        self.searchInput = ko.observable();
        self.jobsPanelVisible = ko.observable(false);
        self.historyPanelVisible = ko.observable(false);

        // TODO: Extract to common module (shared with nav search autocomplete)
        var SEARCH_FACET_ICON = 'fa-tags';
        var SEARCH_TYPE_ICONS = {
          'DATABASE': 'fa-database',
          'TABLE': 'fa-table',
          'VIEW': 'fa-eye',
          'FIELD': 'fa-columns',
          'PARTITION': 'fa-th',
          'SOURCE': 'fa-server',
          'OPERATION': 'fa-cogs',
          'OPERATION_EXECUTION': 'fa-cog',
          'DIRECTORY': 'fa-folder-o',
          'FILE': 'fa-file-o',
          'SUB_OPERATION': 'fa-code-fork',
          'COLLECTION': 'fa-search',
          'HBASE': 'fa-th-large',
          'HUE': 'fa-file-o'
        };

        self.searchAutocompleteSource = function (request, callback) {
          // TODO: Extract complete contents to common module (shared with nav search autocomplete)
          var facetMatch = request.term.match(/([a-z]+):\s*(\S+)?$/i);
          var isFacet = facetMatch !== null;
          var partialMatch = isFacet ? null : request.term.match(/\S+$/);
          var partial = isFacet && facetMatch[2] ? facetMatch[2] : (partialMatch ? partialMatch[0] : '');
          var beforePartial = request.term.substring(0, request.term.length - partial.length);

          self.apiHelper.globalSearchAutocomplete({
            query:  request.term,
            successCallback: function (data) {
              var values = [];
              var facetPartialRe = new RegExp(partial.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"), 'i'); // Protect for 'tags:*axe'

              if (typeof data.resultsHuedocuments !== 'undefined') {
                data.resultsHuedocuments.forEach(function (result) {
                  values.push({ data: { label: result.hue_name, icon: SEARCH_TYPE_ICONS[result.type],  description: result.hue_description }, value: beforePartial + result.originalName });
                });
              }
              if (values.length > 0) {
                values.push({ divider: true });
              }

              if (isFacet && typeof data.facets !== 'undefined') { // Is typed facet, e.g. type: type:bla
                var facetInQuery = facetMatch[1];
                if (typeof data.facets[facetInQuery] !== 'undefined') {
                  $.map(data.facets[facetInQuery], function (count, value) {
                    if (facetPartialRe.test(value)) {
                      values.push({ data: { label: facetInQuery + ':' + value, icon: SEARCH_FACET_ICON, description: count }, value: beforePartial + value})
                    }
                  });
                }
              } else {
                if (typeof data.facets !== 'undefined') {
                  Object.keys(data.facets).forEach(function (facet) {
                    if (facetPartialRe.test(facet)) {
                      if (Object.keys(data.facets[facet]).length > 0) {
                        values.push({ data: { label: facet + ':', icon: SEARCH_FACET_ICON, description: $.map(data.facets[facet], function (key, value) { return value + ' (' + key + ')'; }).join(', ') }, value: beforePartial + facet + ':'});
                      } else { // Potential facet from the list
                        values.push({ data: { label: facet + ':', icon: SEARCH_FACET_ICON, description: '' }, value: beforePartial + facet + ':'});
                      }
                    } else if (partial.length > 0) {
                      Object.keys(data.facets[facet]).forEach(function (facetValue) {
                        if (facetValue.indexOf(partial) !== -1) {
                          values.push({ data: { label: facet + ':' + facetValue, icon: SEARCH_FACET_ICON, description: facetValue }, value: beforePartial + facet + ':' + facetValue });
                        }
                      });
                    }
                  });
                }
              }

              if (values.length > 0) {
                values.push({ divider: true });
              }
              if (typeof data.results !== 'undefined') {
                data.results.forEach(function (result) {
                  values.push({ data: { label: result.hue_name, icon: SEARCH_TYPE_ICONS[result.type],  description: result.hue_description }, value: beforePartial + result.originalName });
                });
              }

              if (values.length > 0 && values[values.length - 1].divider) {
                values.pop();
              }
              if (values.length === 0) {
                values.push({ noMatch: true });
              }
              callback(values);
            },
            silenceErrors: true,
            errorCallback: function () {
              callback([]);
            }
          });
        };
      }

      TopNavViewModel.prototype.performSearch = function () {
      };

      var topNavViewModel = new TopNavViewModel();
      ko.applyBindings(topNavViewModel, $('.top-nav')[0]);
      ko.applyBindings(topNavViewModel, $('.left-nav')[0]);

      return topNavViewModel;
    })(onePageViewModel);

    window.hueDebug = {
      viewModel: function (element) {
        return element ? ko.dataFor(element) : window.hueDebug.onePageViewModel;
      },
      onePageViewModel: onePageViewModel,
      sidePanelViewModel: sidePanelViewModel,
      topNavViewModel: topNavViewModel
    };
  });
</script>

${ commonHeaderFooterComponents.footer(messages) }

</body>
</html>
