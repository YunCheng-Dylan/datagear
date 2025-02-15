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
<#assign Role=statics['org.datagear.management.domain.Role']>
<#--
titleMessageKey 标题标签I18N关键字，不允许null
selectOperation 是否选择操作，允许为null
boolean readonly 是否只读操作，默认为false
-->
<#assign selectOperation=(selectOperation!false)>
<#assign selectPageCss=(selectOperation?string('page-grid-select',''))>
<#assign isMultipleSelect=(isMultipleSelect!false)>
<#assign readonly=(readonly!false)>
<#assign DataSetEntity=statics['org.datagear.management.domain.DataSetEntity']>
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
<#include "../include/page_obj_opt_permission.ftl" >
<div id="${pageId}" class="page-grid ${selectPageCss} page-grid-dataSet">
	<div class="head">
		<div class="search">
			<#include "../include/page_obj_searchform_data_filter.ftl">
			<#include "../include/analysisProjectAware_grid_search.ftl">
		</div>
		<div class="operation" show-any-role="${Role.ROLE_DATA_ADMIN},${Role.ROLE_DATA_ANALYST}">
			<#if selectOperation>
				<button type="button" class="selectButton recommended"><@spring.message code='confirm' /></button>
			</#if>
			<#if readonly>
				<button type="button" class="viewButton"><@spring.message code='view' /></button>
			<#else>
				<div class="add-button-wrapper" show-any-role="${Role.ROLE_DATA_ADMIN}">
					<button type="button" class="add-button">
						<@spring.message code='add' />
						<span class="ui-icon ui-icon-triangle-1-s"></span>
					</button>
					<div class="add-button-panel ui-widget ui-widget-content ui-corner-all ui-widget-shadow ui-front">
						<ul class="add-button-list">
							<li addURL="addForSQL"><div><@spring.message code='dataSet.dataSetType.SQL' /></div></li>
							<li addURL="addForCsvValue"><div><@spring.message code='dataSet.dataSetType.CsvValue' /></div></li>
							<li addURL="addForCsvFile"><div><@spring.message code='dataSet.dataSetType.CsvFile' /></div></li>
							<li addURL="addForExcel"><div><@spring.message code='dataSet.dataSetType.Excel' /></div></li>
							<li addURL="addForHttp"><div><@spring.message code='dataSet.dataSetType.Http' /></div></li>
							<li addURL="addForJsonValue"><div><@spring.message code='dataSet.dataSetType.JsonValue' /></div></li>
							<li addURL="addForJsonFile"><div><@spring.message code='dataSet.dataSetType.JsonFile' /></div></li>
							<li class="ui-widget-header ui-menu-divider ui-widget-content"></li>
							<li addURL="copy"><div><@spring.message code='copy' /></div></li>
						</ul>
					</div>
				</div>
				<#if !selectOperation>
				<button type="button" class="editButton" show-any-role="${Role.ROLE_DATA_ADMIN}"><@spring.message code='edit' /></button>
				</#if>
				<#if !selectOperation>
				<#if !(currentUser.anonymous)>
				<button type="button" class="shareButton" show-any-role="${Role.ROLE_DATA_ADMIN}"><@spring.message code='share' /></button>
				</#if>
				</#if>
				<button type="button" class="viewButton"><@spring.message code='view' /></button>
				<#if !selectOperation>
				<button type="button" class="deleteButton" show-any-role="${Role.ROLE_DATA_ADMIN}"><@spring.message code='delete' /></button>
				</#if>
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
	po.initDataFilter();

	po.currentUser = <@writeJson var=currentUser />;
	
	po.element(".add-button-list").menu(
	{
		select: function(event, ui)
		{
			var item = $(ui.item);
			
			var addURL = item.attr("addURL");
			
			if(addURL == "copy")
			{
				po.executeOnSelect(function(row)
				{
					po.handleAddOperation(po.url(addURL),
					{
						width: "85%",
						data : {"id" : row.id}
					});
				});
			}
			else
			{
				po.handleAddOperation(po.url(addURL), { width: "85%" });
			}
		}
	});
	
	po.url = function(action)
	{
		return "${contextPath}/dataSet/" + action;
	};

	po.element(".add-button").click(function()
	{
		po.element(".add-button-panel").toggle();
	});
	po.element(".add-button-wrapper").hover(function(){}, function()
	{
		po.element(".add-button-panel").hide();
	});
	
	po.element(".editButton").click(function()
	{
		po.handleOpenOfOperation(po.url("edit"), { width: "85%" });
	});
	
	po.element(".viewButton").click(function()
	{
		po.handleOpenOfOperation(po.url("view"), { width: "85%" });
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
			po.open(contextPath+"/authorization/${DataSetEntity.AUTHORIZATION_RESOURCE_TYPE}/" + row.id +"/query", options);
		});
	});
	
	var dataSetTypeColumn = po.buildSimpleColumn("<@spring.message code='dataSet.dataSetType' />", "dataSetType");
	dataSetTypeColumn.render = function(data)
	{
		if("${DataSetEntity.DATA_SET_TYPE_SQL}" == data)
			return "<@spring.message code='dataSet.dataSetType.SQL' />";
		else if("${DataSetEntity.DATA_SET_TYPE_Excel}" == data)
			return "<@spring.message code='dataSet.dataSetType.Excel' />";
		else if("${DataSetEntity.DATA_SET_TYPE_CsvValue}" == data)
			return "<@spring.message code='dataSet.dataSetType.CsvValue' />";
		else if("${DataSetEntity.DATA_SET_TYPE_CsvFile}" == data)
			return "<@spring.message code='dataSet.dataSetType.CsvFile' />";
		else if("${DataSetEntity.DATA_SET_TYPE_JsonValue}" == data)
			return "<@spring.message code='dataSet.dataSetType.JsonValue' />";
		else if("${DataSetEntity.DATA_SET_TYPE_JsonFile}" == data)
			return "<@spring.message code='dataSet.dataSetType.JsonFile' />";
		else if("${DataSetEntity.DATA_SET_TYPE_Http}" == data)
			return "<@spring.message code='dataSet.dataSetType.Http' />";
		else
			return "";
	};
	
	var tableColumns = [
		po.buildSimpleColumn("<@spring.message code='id' />", "id", true),
		po.buildSearchableColumn("<@spring.message code='dataSet.name' />", "name"),
		dataSetTypeColumn,
		po.buildSearchableColumn("<@spring.message code='analysisProject.ownerAnalysisProject' />", "analysisProject.name"),
		po.buildSimpleColumn("<@spring.message code='dataSet.createUser' />", "createUser.realName"),
		po.buildSimpleColumn("<@spring.message code='dataSet.createTime' />", "createTime")
	];
	
	po.initPagination();
	
	var tableSettings = po.buildAjaxTableSettings(tableColumns, po.url("pagingQueryData"));
	tableSettings.order = [[$.getDataTableColumn(tableSettings, "createTime"), "desc"]];
	po.initTable(tableSettings);
	po.handlePermissionElement();
})
(${pageId});
</script>
</body>
</html>
