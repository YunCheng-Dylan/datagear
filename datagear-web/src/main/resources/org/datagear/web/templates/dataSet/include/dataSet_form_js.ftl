<#--
 *
 * Copyright 2018 datagear.tech
 *
 * Licensed under the LGPLv3 license:
 * http://www.gnu.org/licenses/lgpl-3.0.html
 *
-->
<#--
数据集表单页：JS片段

依赖：
page_obj.ftl

变量：
//自上次预览后，预览值是否已修改，不允许为null
po.isPreviewValueModified = function(){ return true || false; };
//预览URL，不允许为null
po.previewOptions.url = "...";
-->
<#assign PropertyDataType=statics['org.datagear.analysis.DataSetProperty$DataType']>
<#assign ParamDataType=statics['org.datagear.analysis.DataSetParam$DataType']>
<#assign ParamInputType=statics['org.datagear.analysis.DataSetParam$InputType']>
<script type="text/javascript">
(function(po)
{
	po.url = function(action)
	{
		return "${contextPath}/dataSet/" + action;
	};
	
	po.isReadonlyOperation = function()
	{
		return ("${readonly?string('true','false')}" == "true");
	};

	po.isAddOperation = function()
	{
		return ("${isAdd?string('true','false')}" == "true");
	};
	
	po.isMutableModel = function()
	{
		return (po.element("[name='mutableModel']:checked").val() == "true");
	};
	
	po.isPreviewValueModified = function()
	{
		return true;
	};
	
	po.isModifiedIgnoreBlank = function(sourceVal, targetVal)
	{
		sourceVal = (sourceVal || "");
		targetVal = (targetVal || "");
		
		sourceVal = sourceVal.replace(/\s/g, '');
		targetVal = targetVal.replace(/\s/g, '');
		
		return sourceVal != targetVal;
	};
	
	po.dataSetParamsTableElement = function()
	{
		return po.elementOfId("${pageId}-dataSetParamsTable");
	};
	
	po.previewResultTableElement = function()
	{
		return po.elementOfId("${pageId}-previewResultTable");
	};
	
	po.dataSetPropertiesTableElement = function()
	{
		return po.elementOfId("${pageId}-dataSetPropertiesTable");
	};

	po.dataFormatPanelElement = function()
	{
		return po.elementOfId("${pageId}-dataFormatPanel");
	};
	
	po.calWorkspaceOperationTableHeight = function()
	{
		var tableTitleHeight = 30;
		return po.element(".preview-result-table-wrapper").height() - tableTitleHeight;
	};
	
	po.initMtableModelInput = function()
	{
		po.element(".mutableModelRadios").checkboxradiogroup();
	};
	
	po.initWorkspaceHeight = function()
	{
		var windowHeight = $(window).height();
		var height = windowHeight;
		
		//减去上下留白
		height = height - height/10;
		//减去对话框标题高度
		if($.isInDialog(po.element()))
			height = height - 41;
		//减去其他表单元素高度
		height = height - po.element(".form-head").outerHeight(true);
		height = height - po.element(".form-foot").outerHeight(true);
		
		var formContentHeight = height - 41;
		
		po.element(".form-content > .form-item").each(function()
		{
			height = height - $(this).outerHeight(true);
		});
		
		//减去杂项高度
		height = height - 41 - 10;
		
		if(height < 300)
			height = 300;
		
		var errorInfoHeight = 41;
		
		po.element(".workspace").css("min-height", height+"px");
		po.element(".workspace-editor-wrapper").height(height - errorInfoHeight);
		po.element(".workspace-operation-wrapper").height(height - errorInfoHeight);
		po.element(".form-content").css("max-height", formContentHeight+"px");
	};
	
	po.createWorkspaceEditor = function(dom, options)
	{
		if(options.readOnly == null)
			options.readOnly = ${readonly?string("true","false")};
		
		if(!options.extraKeys)
			options.extraKeys = {};
		
		options.extraKeys["Ctrl-Enter"] = function(editor)
		{
			var $operationWrapper = po.element(".workspace-operation-wrapper");
    		$operationWrapper.tabs("option", "active", 0);
    		po.element(".preview-button").click();
		};
		
		return po.createCodeEditor(dom, options);
	};
	
	po.initWorkspaceTabs = function(disableParams)
	{
		disableParams = (disableParams == true ? true : false);
		
		po.element(".workspace-operation-wrapper").tabs(
		{
			activate: function(event, ui)
			{
				if(ui.newPanel.hasClass("preview-result-table-wrapper"))
				{
				}
				else if(ui.newPanel.hasClass("params-table-wrapper"))
				{
					var dataTable = po.dataSetParamsTableElement().DataTable();
					$.dataTableUtil.adjustColumn(dataTable);
				}
				else if(ui.newPanel.hasClass("properties-table-wrapper"))
				{
					if(ui.newTab.hasClass("ui-state-highlight"))
						ui.newTab.removeClass("ui-state-highlight");
					
					var dataTable = po.dataSetPropertiesTableElement().DataTable();
					$.dataTableUtil.adjustColumn(dataTable);
				}
			}
		});
		
		if(disableParams)
		{
			po.disableDataSetParamOperation(true);
		}
	};
	
	//获取、设置数据参数选项卡是否禁用
	po.disableDataSetParamOperation = function(disable)
	{
		var nav = $(".workspace-operation-nav", po.element(".workspace-operation-wrapper"));
		var paramsTab = $(".operation-params", nav);
		
		if(disable === undefined)
			return paramsTab.hasClass("ui-state-disabled");
		else
		{
			var paramsIndex = paramsTab.index();
			
			if(disable)
				po.element(".workspace-operation-wrapper").tabs("disable", paramsIndex);
			else
				po.element(".workspace-operation-wrapper").tabs("enable", paramsIndex);
		}
	};
	
	//获取用于添加数据集属性的名
	po.getAddPropertyName = function()
	{
		return "";
	};
	
	po.initDataSetPropertiesTable = function(initDataSetProperties)
	{
		po.dataSetPropertiesTableElement().dataTable(
		{
			"columns" :
			[
				$.dataTableUtil.buildCheckCloumn("<@spring.message code='select' />"),
				{
					title: "<@spring.message code='dataSet.DataSetProperty.name' />",
					data: "name",
					render: function(data, type, row, meta)
					{
						var manual = row.manual;
						return "<input type='text' value='"+$.escapeHtml(data)+"'"
							+" class='dataSetPropertyName input-in-table "+(manual ? "manual" : "readonly")+" ui-widget ui-widget-content ui-corner-all'"
							+" "+(manual ? "" : "readonly='readonly'")+" />";
					},
					width: "8em",
					defaultContent: "",
					orderable: true
				},
				{
					title: "<@spring.message code='dataSet.DataSetProperty.type' />",
					data: "type",
					render: function(data, type, row, meta)
					{
						data = (data || "${PropertyDataType.STRING}");
						
						return "<select class='dataSetPropertyType input-in-table ui-widget ui-widget-content ui-corner-all'>"
								+"<option value='${PropertyDataType.STRING}' "+(data == "${PropertyDataType.STRING}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetProperty.DataType.STRING' /></option>"
								+"<option value='${PropertyDataType.NUMBER}' "+(data == "${PropertyDataType.NUMBER}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetProperty.DataType.NUMBER' /></option>"
								+"<option value='${PropertyDataType.INTEGER}' "+(data == "${PropertyDataType.INTEGER}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetProperty.DataType.INTEGER' /></option>"
								+"<option value='${PropertyDataType.DECIMAL}' "+(data == "${PropertyDataType.DECIMAL}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetProperty.DataType.DECIMAL' /></option>"
								+"<option value='${PropertyDataType.DATE}' "+(data == "${PropertyDataType.DATE}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetProperty.DataType.DATE' /></option>"
								+"<option value='${PropertyDataType.TIME}' "+(data == "${PropertyDataType.TIME}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetProperty.DataType.TIME' /></option>"
								+"<option value='${PropertyDataType.TIMESTAMP}' "+(data == "${PropertyDataType.TIMESTAMP}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetProperty.DataType.TIMESTAMP' /></option>"
								+"<option value='${PropertyDataType.BOOLEAN}' "+(data == "${PropertyDataType.BOOLEAN}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetProperty.DataType.BOOLEAN' /></option>"
								+"<option value='${PropertyDataType.UNKNOWN}' "+(data == "${PropertyDataType.UNKNOWN}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetProperty.DataType.UNKNOWN' /></option>"
								+"</select>";
					},
					width: "6em",
					defaultContent: "",
					orderable: true
				},
				{
					title: $.buildDataTablesColumnTitleWithTip("<@spring.message code='dataSet.DataSetProperty.label' />", "<@spring.message code='dataSet.DataSetProperty.label.desc' />"),
					data: "label",
					render: function(data, type, row, meta)
					{
						return "<input type='text' value='"+$.escapeHtml(data)+"' class='dataSetPropertyLabel input-in-table ui-widget ui-widget-content ui-corner-all' />";
					},
					width: "8em",
					defaultContent: "",
					orderable: true
				},
				{
					title: $.buildDataTablesColumnTitleWithTip("<@spring.message code='dataSet.DataSetProperty.defaultValue' />", "<@spring.message code='dataSet.DataSetProperty.defaultValue.desc' />"),
					data: "defaultValue",
					render: function(data, type, row, meta)
					{
						return "<input type='text' value='"+$.escapeHtml(data)+"' class='dataSetPropertyDefaultValue input-in-table ui-widget ui-widget-content ui-corner-all' />";
					},
					width: "6em",
					defaultContent: "",
					orderable: true
				}
			],
			data: (initDataSetProperties || []),
			"scrollX": true,
			"autoWidth": true,
			"scrollY" : po.calWorkspaceOperationTableHeight(),
	        "scrollCollapse": false,
			"paging" : false,
			"searching" : false,
			"ordering": false,
			"fixedColumns": { leftColumns: 1 },
			"select" : { style : 'os' },
		    "language":
		    {
				"emptyTable": "<@spring.message code='dataSet.noDataSetPropertyDefined' />",
				"zeroRecords" : "<@spring.message code='dataSet.noDataSetPropertyDefined' />"
			}
		});
		
		$.dataTableUtil.bindCheckColumnEvent(po.dataSetPropertiesTableElement().DataTable());
		
		po.element(".add-property-button").click(function()
		{
			var rowData =
			{
				name: (po.getAddPropertyName() || ""),
				type: "${PropertyDataType.STRING}",
				label: "",
				manual: true
			};
			
			po.dataSetPropertiesTableElement().DataTable().row.add(rowData).draw();
		});
		
		po.element(".del-property-button").click(function()
		{
			$.dataTableUtil.deleteSelectedRows(po.dataSetPropertiesTableElement().DataTable());
		});
		
		po.element(".up-property-button").click(function()
		{
			var dataTable = po.dataSetPropertiesTableElement().DataTable();
			$.setDataTableData(dataTable, po.getFormDataSetProperties(true));
			$.dataTableUtil.moveSelectedUp(dataTable);
		});
		
		po.element(".down-property-button").click(function()
		{
			var dataTable = po.dataSetPropertiesTableElement().DataTable();
			$.setDataTableData(dataTable, po.getFormDataSetProperties(true));
			$.dataTableUtil.moveSelectedDown(dataTable);
		});

		po.element(".dataformat-button").click(function()
		{
			po.dataFormatPanelElement().toggle();
		});
		
		po.dataSetPropertiesTableElement().on("click", ".input-in-table", function(event)
		{
			//阻止行选中
			event.stopPropagation();
		});
	};
	
	po.hasFormDataSetProperty = function()
	{
		var $names = po.element(".properties-table-wrapper .dataSetPropertyName");
		return ($names.length > 0);
	};
	
	po.getFormDataSetProperties = function(manualInfoReturn)
	{
		manualInfoReturn = (manualInfoReturn == true ? true : false);
		
		var properties = [];
		
		po.element(".properties-table-wrapper .dataSetPropertyName").each(function(i)
		{
			properties[i] = {};
			var $this = $(this);
			properties[i]["name"] = $this.val();
			if(manualInfoReturn)
				properties[i]["manual"] = $this.hasClass("manual");
		});
		po.element(".properties-table-wrapper .dataSetPropertyType").each(function(i)
		{
			properties[i]["type"] = $(this).val();
		});
		po.element(".properties-table-wrapper .dataSetPropertyLabel").each(function(i)
		{
			properties[i]["label"] = $(this).val();
		});
		po.element(".properties-table-wrapper .dataSetPropertyDefaultValue").each(function(i)
		{
			properties[i]["defaultValue"] = $(this).val();
		});
		
		return properties;
	};
	
	po.updateFormDataSetProperties = function(dataSetProperties)
	{
		dataSetProperties = (dataSetProperties || []);
		var prevProperties = po.getFormDataSetProperties(true);
		var updateProperties = [];
		
		//添加后台自动解析的属性
		for(var i=0; i<dataSetProperties.length; i++)
		{
			var prev = $.findInArray(prevProperties, dataSetProperties[i].name, "name", true);
			
			//添加同名的旧属性，因为用户可能已编辑；否则，添加新属性
			if(prev != null)
				updateProperties.push(prev);
			else
				updateProperties.push(dataSetProperties[i]);
		}
		
		//添加用户手动添加的属性
		for(var i=0; i<prevProperties.length; i++)
		{
			if(prevProperties[i].manual == true)
			{
				var exists = $.findInArray(updateProperties, prevProperties[i].name, "name", true);
				if(exists == null)
					updateProperties.push(prevProperties[i]);
			}
		}
		
		$.addDataTableData(po.dataSetPropertiesTableElement().DataTable(), updateProperties, 0);
		
		po.element(".operation-properties").addClass("ui-state-highlight");
	};
	
	//获取用于添加数据集参数的参数名
	po.getAddParamName = function()
	{
		return po.getAddPropertyName();
	};
	
	po.initDataSetParamsTable = function(initDataSetParams)
	{
		po.dataSetParamsTableElement().dataTable(
		{
			"columns" :
			[
				$.dataTableUtil.buildCheckCloumn("<@spring.message code='select' />"),
				{
					title: "<@spring.message code='dataSet.DataSetParam.name' />",
					data: "name",
					render: function(data, type, row, meta)
					{
						return "<input type='text' value='"+$.escapeHtml(data)+"' class='dataSetParamName input-in-table ui-widget ui-widget-content ui-corner-all' />";
					},
					width: "8em",
					defaultContent: "",
					orderable: true
				},
				{
					title: "<@spring.message code='dataSet.DataSetParam.type' />",
					data: "type",
					render: function(data, type, row, meta)
					{
						data = (data || "${ParamDataType.STRING}");
						
						return "<select class='dataSetParamType input-in-table ui-widget ui-widget-content ui-corner-all'>"
								+"<option value='${ParamDataType.STRING}' "+(data == "${ParamDataType.STRING}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.DataType.STRING' /></option>"
								+"<option value='${ParamDataType.NUMBER}' "+(data == "${ParamDataType.NUMBER}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.DataType.NUMBER' /></option>"
								+"<option value='${ParamDataType.BOOLEAN}' "+(data == "${ParamDataType.BOOLEAN}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.DataType.BOOLEAN' /></option>"
								+"</select>";
					},
					width: "6em",
					defaultContent: "",
					orderable: true
				},
				{
					title: "<@spring.message code='dataSet.DataSetParam.required' />",
					data: "required",
					render: function(data, type, row, meta)
					{
						data = data + "";
						
						return "<select class='dataSetParamRequired input-in-table ui-widget ui-widget-content ui-corner-all'>"
								+"<option value='true' "+(data != "false" ? "selected='selected'" : "")+"><@spring.message code='yes' /></option>"
								+"<option value='false' "+(data == "false" ? "selected='selected'" : "")+"><@spring.message code='no' /></option>"
								+"</select>";
					},
					width: "4em",
					defaultContent: "",
					orderable: true
				},
				{
					title: "<@spring.message code='dataSet.DataSetParam.desc' />",
					data: "desc",
					render: function(data, type, row, meta)
					{
						return "<input type='text' value='"+$.escapeHtml(data)+"' class='dataSetParamDesc input-in-table ui-widget ui-widget-content ui-corner-all' />";
					},
					width: "6em",
					defaultContent: "",
					orderable: true
				},
				{
					title: "<@spring.message code='dataSet.DataSetParam.inputType' />",
					data: "inputType",
					render: function(data, type, row, meta)
					{
						data = (data || "${ParamInputType.TEXT}");
						
						return "<select class='dataSetParamInputType input-in-table ui-widget ui-widget-content ui-corner-all'>"
								+"<option value='${ParamInputType.TEXT}' "+(data == "${ParamInputType.TEXT}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.InputType.TEXT' /></option>"
								+"<option value='${ParamInputType.SELECT}' "+(data == "${ParamInputType.SELECT}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.InputType.SELECT' /></option>"
								+"<option value='${ParamInputType.DATE}' "+(data == "${ParamInputType.DATE}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.InputType.DATE' /></option>"
								+"<option value='${ParamInputType.TIME}' "+(data == "${ParamInputType.TIME}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.InputType.TIME' /></option>"
								+"<option value='${ParamInputType.DATETIME}' "+(data == "${ParamInputType.DATETIME}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.InputType.DATETIME' /></option>"
								+"<option value='${ParamInputType.RADIO}' "+(data == "${ParamInputType.RADIO}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.InputType.RADIO' /></option>"
								+"<option value='${ParamInputType.CHECKBOX}' "+(data == "${ParamInputType.CHECKBOX}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.InputType.CHECKBOX' /></option>"
								+"<option value='${ParamInputType.TEXTAREA}' "+(data == "${ParamInputType.TEXTAREA}" ? "selected='selected'" : "")+"><@spring.message code='dataSet.DataSetParam.InputType.TEXTAREA' /></option>"
								+"</select>";
					},
					width: "6em",
					defaultContent: "",
					orderable: true
				},
				{
					title: "<@spring.message code='dataSet.DataSetParam.inputPayload' />",
					data: "inputPayload",
					render: function(data, type, row, meta)
					{
						return "<textarea class='dataSetParamInputPayload input-in-table ui-widget ui-widget-content ui-corner-all' style='height:2em;'>"+$.escapeHtml(data)+"</textarea>";
					},
					width: "20em",
					defaultContent: "",
					orderable: true
				}
			],
			data: (initDataSetParams || []),
			"scrollX": true,
			"autoWidth": true,
			"scrollY" : po.calWorkspaceOperationTableHeight(),
	        "scrollCollapse": false,
			"paging" : false,
			"searching" : false,
			"ordering": false,
			"fixedColumns": { leftColumns: 1 },
			"select" : { style : 'os' },
		    "language":
		    {
				"emptyTable": "<@spring.message code='dataSet.noDataSetParamDefined' />",
				"zeroRecords" : "<@spring.message code='dataSet.noDataSetParamDefined' />"
			}
		});
		
		$.dataTableUtil.bindCheckColumnEvent(po.dataSetParamsTableElement().DataTable());
		
		po.element(".add-param-button").click(function()
		{
			var name = (po.getAddParamName() || "");
			
			po.dataSetParamsTableElement().DataTable().row.add({ name: name, type: "${ParamDataType.STRING}", required: true, desc: "" }).draw();
		});
		
		po.element(".del-param-button").click(function()
		{
			$.dataTableUtil.deleteSelectedRows(po.dataSetParamsTableElement().DataTable());
		});
		
		po.element(".up-param-button").click(function()
		{
			var dataTable = po.dataSetParamsTableElement().DataTable();
			$.setDataTableData(dataTable, po.getFormDataSetParams());
			$.dataTableUtil.moveSelectedUp(dataTable);
		});
		
		po.element(".down-param-button").click(function()
		{
			var dataTable = po.dataSetParamsTableElement().DataTable();
			$.setDataTableData(dataTable, po.getFormDataSetParams());
			$.dataTableUtil.moveSelectedDown(dataTable);
		});
		
		po.dataSetParamsTableElement().on("click", ".input-in-table", function(event)
		{
			//阻止行选中
			event.stopPropagation();
		});
	};

	po.hasFormDataSetParam = function()
	{
		if(po.disableDataSetParamOperation())
			return false;
		
		var $names = po.element(".params-table-wrapper .dataSetParamName");
		return ($names.length > 0);
	};
	
	po.getFormDataSetParams = function()
	{
		var params = [];
		
		if(po.disableDataSetParamOperation())
			return params;
		
		po.element(".params-table-wrapper .dataSetParamName").each(function(i)
		{
			params[i] = {};
			params[i]["name"] = $(this).val();
		});
		po.element(".params-table-wrapper .dataSetParamType").each(function(i)
		{
			params[i]["type"] = $(this).val();
		});
		po.element(".params-table-wrapper .dataSetParamRequired").each(function(i)
		{
			params[i]["required"] = $(this).val();
		});
		po.element(".params-table-wrapper .dataSetParamDesc").each(function(i)
		{
			params[i]["desc"] = $(this).val();
		});
		po.element(".params-table-wrapper .dataSetParamInputType").each(function(i)
		{
			params[i]["inputType"] = $(this).val();
		});
		po.element(".params-table-wrapper .dataSetParamInputPayload").each(function(i)
		{
			params[i]["inputPayload"] = $(this).val();
		});
		
		return params;
	};
	
	po.initPreviewParamValuePanel = function()
	{
		po.element(".preview-param-value-panel").draggable({ handle : ".ui-widget-header" });
	}
	
	po.showDataSetParamValuePanel = function(formOptions)
	{
		var $panel = po.element(".preview-param-value-panel");
		var $panelContent = $(".preview-param-value-panel-content", $panel);
		
		formOptions = $.extend(
		{
			submitText: "<@spring.message code='confirm' />",
			yesText: "<@spring.message code='yes' />",
			noText: "<@spring.message code='no' />",
			paramValues: chartFactory.chartSetting.getDataSetParamValueObj(chartFactory.chartSetting.getDataSetParamValueForm($panel)),
			render: function()
			{
				$("select, input, textarea", this).addClass("ui-widget ui-widget-content ui-corner-all");
				$("button", this).addClass("ui-button ui-corner-all ui-widget");
			}
		},
		formOptions);
		
		chartFactory.chartSetting.removeDatetimePickerRoot();
		$panelContent.empty();
		
		chartFactory.chartSetting.renderDataSetParamValueForm($panelContent,
				po.getFormDataSetParams(), formOptions);
		
		$panel.show();
		$panel.position({ my : "right top", at : "left+5 top", of : po.element(".workspace-operation-wrapper")});
	};
	
	po.resultFetchSizeDefault = 100;
	
	//预览设置项
	po.previewOptions =
	{
		//预览请求URL，必须设置
		url: null,
		//预览请求参数数据
		data:
		{
			dataSet: {},
			query: { resultFetchSize: po.resultFetchSizeDefault }
		},
		//预览操作前置回调函数，返回false阻止
		beforePreview: function(){},
		//刷新操作前置回调函数，返回false阻止
		beforeRefresh: function(){},
		//预览请求前置回调函数，返回false阻止
		beforeRequest: function(){},
		//预览响应构建表格列数组
		buildTablesColumns: function(previewResponse)
		{
			return po.buildDataSetPropertiesColumns(previewResponse.properties);
		},
		//预览请求成功回调函数
		success: function(previewResponse){},
		//预览出错回调函数，返回非空字符串表明将其显示在错误信息区内
		error: function(operationMessage, jqXHR)
		{
			if(operationMessage && operationMessage.data)
				return operationMessage.data[1];
		}
	};
	
	po.resultFetchSizeVal = function(val)
	{
		var $input = po.element(".resultFetchSizeInput");
		
		if(val === undefined)
		{
			val = parseInt($input.val());
			var validVal = val;
			
			if(isNaN(validVal))
				validVal = po.resultFetchSizeDefault;
			else if(validVal < 1)
				validVal = 1;
			
			if(validVal != val)
			{
				val = validVal;
				$input.val(val);
			}
			
			return val;
		}
		else
			$input.val(val);
	};
	
	po.getFormDataFormat = function()
	{
		var df =
		{
			"dateFormat": po.elementOfName("dataFormat.dateFormat").val(),
			"timeFormat": po.elementOfName("dataFormat.timeFormat").val(),
			"timestampFormat": po.elementOfName("dataFormat.timestampFormat").val(),
			"numberFormat": po.elementOfName("dataFormat.numberFormat").val()
		};
		
		return df;
	};
	
	//获取、设置上一次预览是否成功
	po.previewSuccess = function(success)
	{
		if(success === undefined)
			return po._previewSuccess == true;
		else
			po._previewSuccess = success;
	};
	
	po.destroyPreviewResultTable = function()
	{
		var table = po.previewResultTableElement();
		if($.isDatatTable(table))
		{
			table.DataTable().destroy();
			table.empty();
		}
	};
	
	po.isPreviewParamPropertyDataFormatModified = function()
	{
		var formParams = (po.getFormDataSetParams() || []);
		var formProperties = (po.getFormDataSetProperties() || []);
		var formDataFormat = (po.getFormDataFormat() || {});
		var params = (po.previewOptions.data.dataSet.params || []);
		var properties = (po.previewOptions.data.dataSet.properties || []);
		var dataFormat = (po.previewOptions.data.dataSet.dataFormat || {});
		
		//参数数组大小必须一致，因为不一致有可能影响数据集结果
		if(formParams.length != params.length)
			return true;
		
		for(var i=0; i<formParams.length; i++)
		{
			var fp = formParams[i];
			var p = $.findInArray(params, fp.name, "name", true);
			
			if(p == null || fp.name != p.name || fp.type != p.type || fp.required != p.required
					|| fp.inputType != p.inputType || fp.inputPayload != p.inputPayload)
			{
				return true;
			}
		}
		
		//属性数组大小不必一致，因为不一致不一定影响数据集结果
		for(var i=0; i<formProperties.length; i++)
		{
			var fp = formProperties[i];
			var p = $.findInArray(properties, fp.name, "name", true);
			
			if(p == null || fp.name != p.name || fp.type != p.type || fp.defaultValue != p.defaultValue)
			{
				return true;
			}
		}
		
		if(formDataFormat.dateFormat != dataFormat.dateFormat || formDataFormat.timeFormat != dataFormat.timeFormat
				|| formDataFormat.timestampFormat != dataFormat.timestampFormat || formDataFormat.numberFormat != dataFormat.numberFormat)
		{
			return true;
		}
		
		return false;
	};
	
	po.initParamPropertyDataFormat = function(params, properties)
	{
		po.initDataSetParamsTable(po.dataSetParams);
		po.initDataSetPropertiesTable(po.dataSetProperties);
		po.initPreviewParamValuePanel();
	};
	
	po.buildPreviewOptionsDataSetProperties = function()
	{
		var isAddOperation = po.isAddOperation();
		
		//编辑操作无法区分已保存的属性是否是用户手动添加的，所以应全部返回
		if(!isAddOperation)
			return po.getFormDataSetProperties();
		
		var re = [];
		
		var formDataSetProperties = po.getFormDataSetProperties(true);
		var canReturnEmpty = true;
		
		//对于添加操作时，如果没有手动添加属性，也没有对后台生成的属性做过修改，则可以返回空数组；否则，应全部返回
		var prevGenDataSetProperties = (po.prevGenDataSetProperties || []);
		for(var i=0; i<formDataSetProperties.length; i++)
		{
			var fdsp = formDataSetProperties[i];
			
			//手动添加属性必须加入
			if(fdsp.manual)
			{
				canReturnEmpty = false;
				break;
			}
			else
			{
				var gdsp = (prevGenDataSetProperties[i] || {});
				var fdspType = (fdsp.type || ""), fdspLabel = (fdsp.label || ""), fdspDefaultValue = (fdsp.defaultValue || "");
				var gdspType = (gdsp.type || ""), gdspLabel = (gdsp.label || ""), gdspDefaultValue = (gdsp.defaultValue || "");
				
				//顺序调整、字段修改了则应加入
				if(fdsp.name != gdsp.name || fdspType != gdspType ||  fdspLabel != gdspLabel
						|| fdspDefaultValue != gdspDefaultValue)
				{
					canReturnEmpty = false;
					break;
				}
			}
		}
		
		if(!canReturnEmpty)
			re = po.getFormDataSetProperties();
		
		return re;
	};
	
	po.initPreviewOperations = function()
	{
		po.previewOptions.data.dataSet.params = po.getFormDataSetParams();
		po.previewOptions.data.dataSet.properties = po.getFormDataSetProperties();
		po.previewOptions.data.dataSet.dataFormat = po.getFormDataFormat();
		
		po.element(".preview-result-table-wrapper .preview-button").click(function(event)
		{
			var previewValueModified = po.isPreviewValueModified();
			
			if(po.previewOptions.beforePreview() == false)
				return;
			
			po.previewOptions.data.dataSet.id = po.elementOfName("id").val();
			po.previewOptions.data.dataSet.name = po.elementOfName("name").val();
			
			if(po.hasFormDataSetParam())
			{
				//避免设置参数面板被隐藏
				event.stopPropagation();
				
				po.showDataSetParamValuePanel(
				{
					submit: function()
					{
						po.destroyPreviewResultTable();
						
						po.previewOptions.data.dataSet.params = po.getFormDataSetParams();
						po.previewOptions.data.query.paramValues = chartFactory.chartSetting.getDataSetParamValueObj(this);
						
						po.executePreview(previewValueModified);
					}
				});
			}
			else
			{
				po.destroyPreviewResultTable();
				
				po.previewOptions.data.dataSet.params = [];
				po.previewOptions.data.query.paramValues = {};
				
				po.executePreview(previewValueModified);
			}
		});
		
		po.element(".preview-result-table-wrapper .refresh-button").click(function()
		{
			if(po.previewOptions.beforeRefresh() == false)
				return;
			
			po.executePreview(false);
		});
		
		po.element(".show-resolved-source-button").click(function()
		{
			var $panel = po.element(".result-resolved-source-panel");
			
			if($panel.is(":hidden"))
			{
				$panel.show();
				$panel.position({ my: "right bottom", at: "right top-5", of: this });
			}
			else
				$panel.hide();
		});
		
		po.resultFetchSizeVal(po.resultFetchSizeDefault);
		po.element(".resultFetchSizeInput").on("keydown", function(e)
		{
			//防止提交数据集表单
			if(e.keyCode == $.ui.keyCode.ENTER)
				return false;
		});
	};
	
	po.executePreview = function(previewValueModified)
	{
		if(po.previewOptions.beforeRequest() == false)
			return;
		
		var $buttons = po.element(".preview-result-table-wrapper > .operation > button");
		$buttons.each(function()
		{
			$(this).button("disable");
		});
		
		po.element(".preview-error-info").hide();
		po.element(".preview-result-foot").hide();
		
		var table = po.previewResultTableElement();
		var initDataTable = !$.isDatatTable(table);
		
		po.previewOptions.data.query.resultFetchSize = po.resultFetchSizeVal();
		po.previewOptions.data.dataSet.dataFormat = po.getFormDataFormat();
		po.previewOptions.data.dataSet.properties = po.buildPreviewOptionsDataSetProperties();
		
		$.ajaxJson(
		{
			url : po.previewOptions.url,
			data : po.previewOptions.data,
			success : function(previewResponse)
			{
				po.previewSuccess(true);
				
				po.prevGenDataSetProperties = $.extend(true, [], previewResponse.properties);
				
				//工作区内容有变更才更新属性，防止用户添加的属性输入框被刷新
				//属性表单内容为空也更新，比如用户删除了所有属性时
				if(!po.isMutableModel() && !po.isReadonlyOperation() && (previewValueModified || !po.hasFormDataSetProperty()))
				{
					po.updateFormDataSetProperties(previewResponse.properties);
					po.previewOptions.data.dataSet.properties = po.getFormDataSetProperties();
				}
				
				var tableData = (previewResponse.result.data || []);
				if(!$.isArray(tableData))
					tableData = [ tableData ];
				
				if(initDataTable)
				{
					var columns = po.previewOptions.buildTablesColumns(previewResponse);
					
					var newColumns = [
						{
							title: "<@spring.message code='rowNumber' />", data: null, defaultContent: "",
							render: po.renderRowNumberColumn, className: "column-row-number", width: "3em"
						}
					];
					newColumns = newColumns.concat(columns);
					
					var settings =
					{
						"columns" : newColumns,
						"data" : tableData,
						"scrollX": true,
						"autoWidth": true,
						"scrollY" : po.calWorkspaceOperationTableHeight(),
				        "scrollCollapse": false,
						"paging" : false,
						"searching" : false,
						"ordering": false,
						"select" : { style : 'os' },
					    "language":
					    {
							"emptyTable": "<@spring.message code='dataTables.noData' />",
							"zeroRecords" : "<@spring.message code='dataTables.zeroRecords' />"
						}
					};
					
					table.addClass("preview-result-table-inited");
					table.dataTable(settings);
					
					po.element(".preview-result-foot").show();
					
					if(previewResponse.templateResult)
					{
						po.element(".result-resolved-source textarea").val(previewResponse.templateResult);
						po.element(".result-resolved-source").show();
					}
					else
					{
						po.element(".result-resolved-source textarea").val("");
						po.element(".result-resolved-source").hide();
					}
				}
				else
				{
					var dataTable = table.DataTable();
					$.addDataTableData(dataTable, tableData, 0);
					
					po.element(".preview-result-foot").show();
				}
				
				po.previewOptions.success(previewResponse);
			},
			error: function(jqXHR)
			{
				po.previewSuccess(false);
				
				var errorInfo = po.previewOptions.error(jqXHR.responseJSON, jqXHR);
				
				if(errorInfo)
				{
					po.element(".preview-error-info textarea").val(errorInfo);
					po.element(".preview-error-info").show();
				}
			},
			complete: function()
			{
				$buttons.each(function()
				{
					$(this).button("enable");
				});
			}
		});
	};
	
	po.renderRowNumberColumn = function(data, type, row, meta)
	{
		var row = meta.row;
		
		if(row.length > 0)
			row = row[0];
		
		return row + 1;
	};
	
	po.buildDataSetPropertiesColumns = function(dataSetProperties)
	{
		dataSetProperties = (dataSetProperties || []);
		
		var columns = [];
		for(var i=0; i<dataSetProperties.length; i++)
		{
			columns[i] =
			{
				title: dataSetProperties[i].name,
				//XXX 这里data不能直接使用dataSetProperties[i].name，
				//因为其中可能包含特殊字符（比如：'.'），而导致值无法展示
				data: function(row, type, setValue, meta)
				{
					//第0列被序号列占用，所以这里要减1
					var colIndex = (meta.col - 1);
					
					var name = dataSetProperties[colIndex].name;
					
					if(setValue === undefined)
						return chartFactory.escapeHtml(row[name]);
					else
						row[name] = setValue;
				},
				defaultContent: "",
			};
		}
		
		return columns;
	};
})
(${pageId});
</script>