<#--
 *
 * Copyright 2018 datagear.tech
 *
 * Licensed under the LGPLv3 license:
 * http://www.gnu.org/licenses/lgpl-3.0.html
 *
-->
<#include "../include/page_import.ftl">
<#include "../include/html_doctype.ftl">
<#--
titleMessageKey 标题标签I18N关键字，不允许null
selectOperation 是否选择操作，允许为null
-->
<#assign selectOperation=(selectOperation!false)>
<#assign selectPageCss=(selectOperation?string('page-grid-select',''))>
<html>
<head>
<#include "../include/html_head.ftl">
<title><#include "../include/html_title_app_name.ftl"><@spring.message code='${titleMessageKey}' /></title>
</head>
<body class="fill-parent">
<#if !isAjaxRequest>
<div class="fill-parent">
</#if>
<#include "../include/page_obj.ftl">
<div id="${pageId}" class="page-grid ${selectPageCss} page-grid-hidden-foot page-grid-driverEntity">
	<div class="head">
		<div class="search">
			<#include "../include/page_obj_searchform.ftl">
		</div>
		<div class="operation">
			<#if selectOperation>
				<button type="button" class="selectButton recommended"><@spring.message code='confirm' /></button>
				<button type="button" class="viewButton"><@spring.message code='view' /></button>
			<#else>
				<#--
				<button type="button" class="importButton"><@spring.message code='import' /></button>
				<button type="button" class="exportButton"><@spring.message code='export' /></button>
				-->
				<button class="addButton" type="button"><@spring.message code='add' /></button>
				<button class="editButton" type="button"><@spring.message code='edit' /></button>
				<button class="viewButton" type="button"><@spring.message code='view' /></button>
				<button class="deleteButton" type="button"><@spring.message code='delete' /></button>
			</#if>
		</div>
	</div>
	<div class="content">
		<table id="${pageId}-table" width="100%" class="hover stripe">
		</table>
	</div>
	<div class="foot">
		<div class="pagination-wrapper">
			<div id="${pageId}-pagination" class="pagination"></div>
		</div>
	</div>
</div>
<#if !isAjaxRequest>
</div>
</#if>
<#include "../include/page_obj_grid.ftl">
<script type="text/javascript">
(function(po)
{
	po.initGridBtns();
	
	po.url = function(action)
	{
		return "${contextPath}/driverEntity/" + action;
	};
	
	po.element(".addButton").click(function()
	{
		po.handleAddOperation(po.url("add"));
	});
	
	po.element(".importButton").click(function()
	{
		po.open(po.url("import"));
	});

	po.element(".exportButton").click(function()
	{
		var selectedDatas = po.getSelectedData();
		var param = $.getPropertyParamString(selectedDatas, "id");
		
		var options = {target : "_file"};
		
		po.open(po.url("export?"+param), options);
	});
	
	po.element(".editButton").click(function()
	{
		po.handleOpenOfOperation(po.url("edit"));
	});

	po.element(".viewButton").click(function()
	{
		po.handleOpenOfOperation(po.url("view"));
	});
	
	po.element(".deleteButton").click(function()
	{
		po.handleDeleteOperation(po.url("delete"));
	});
	
	po.element(".selectButton").click(function()
	{
		po.handleSelectOperation();
	});
	
	var tableColumns = [
		po.buildSimpleColumn("<@spring.message code='driverEntity.id' />", "id", true),
		po.buildSearchableColumn("<@spring.message code='driverEntity.displayName' />", "displayName"),
		po.buildSearchableColumn("<@spring.message code='driverEntity.driverClassName' />", "driverClassName"),
		po.buildSearchableColumn("<@spring.message code='driverEntity.displayDesc' />", "displayDescMore"),
		po.buildSimpleColumn("", "displayText", true)
	];
	var tableSettings = po.buildAjaxTableSettings(tableColumns, po.url("queryData"));
	po.initTable(tableSettings);
})
(${pageId});
</script>
</body>
</html>
