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
<#assign DataSetResDirectory=statics['org.datagear.management.domain.DataSetResDirectory']>
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
<div id="${pageId}" class="page-grid ${selectPageCss} page-grid-dataSetResDirectory">
	<div class="head">
		<div class="search search-dataSetResDirectory">
			<#include "../include/page_obj_searchform.ftl">
		</div>
		<div class="operation">
			<#if selectOperation>
				<button type="button" class="selectButton recommended"><@spring.message code='confirm' /></button>
				<button type="button" class="viewButton view-button"><@spring.message code='view' /></button>
			<#else>
				<button type="button" class="addButton"><@spring.message code='add' /></button>
				<button type="button" class="editButton"><@spring.message code='edit' /></button>
				<button type="button" class="viewButton"><@spring.message code='view' /></button>
				<#if !(currentUser.anonymous)>
				<button type="button" class="shareButton"><@spring.message code='share' /></button>
				</#if>
				<button type="button" class="deleteButton"><@spring.message code='delete' /></button>
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
<#include "../include/page_obj_pagination.ftl">
<#include "../include/page_obj_grid.ftl">
<#include "../include/page_obj_data_permission.ftl" >
<script type="text/javascript">
(function(po)
{
	po.initGridBtns();
	
	po.currentUser = <@writeJson var=currentUser />;
	
	po.url = function(action)
	{
		return "${contextPath}/dataSetResDirectory/" + action;
	};

	po.element(".addButton").click(function()
	{
		po.handleAddOperation(po.url("add"));
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
	
	po.element(".shareButton").click(function()
	{
		po.executeOnSelect(function(row)
		{
			if(!po.canAuthorize(row, po.currentUser))
			{
				$.tipInfo("<@spring.message code='error.PermissionDeniedException' />");
				return;
			}
			
			var options = {};
			$.setGridPageHeightOption(options);
			po.open(contextPath+"/authorization/${DataSetResDirectory.AUTHORIZATION_RESOURCE_TYPE}/" + row.id +"/query", options);
		});
	});
	
	var tableColumns = [
		po.buildSimpleColumn("<@spring.message code='id' />", "id", true),
		po.buildSearchableColumn("<@spring.message code='dataSetResDirectory.directory' />", "directory"),
		po.buildSearchableColumn("<@spring.message code='dataSetResDirectory.desc' />", "desc"),
		po.buildSimpleColumn("<@spring.message code='dataSetResDirectory.createUser' />", "createUser.realName", true),
		po.buildSimpleColumn("<@spring.message code='dataSetResDirectory.createTime' />", "createTime", true)
	];
	
	po.initPagination();
	
	var tableSettings = po.buildAjaxTableSettings(tableColumns, po.url("pagingQueryData"));
	po.initTable(tableSettings);
})
(${pageId});
</script>
</body>
</html>
