<#--
 *
 * Copyright 2018 datagear.tech
 *
 * Licensed under the LGPLv3 license:
 * http://www.gnu.org/licenses/lgpl-3.0.html
 *
-->
<#--
导入公用片段

String dataExchangeId 数据交换ID

依赖：
dataExchange_js.ftl

-->
<script type="text/javascript">
(function(po)
{
	po.dependentNumberInputPlaceholder = "";
	
	po.addSubDataExchangesForFileInfos = function(fileInfos)
	{
		if(!fileInfos.length)
			return;
		
		if(!po.nextSubDataExchangeNumberSeq || po.nextSubDataExchangeNumberSeq < 1)
			po.nextSubDataExchangeNumberSeq = 1;
		else
		{
			var dataTable = po.getSubDataExchangeDataTable();
			var rowCount = dataTable.rows().indexes().length;
			if(rowCount == 0)
				po.nextSubDataExchangeNumberSeq = 1;
		}
		
		for(var i=0; i<fileInfos.length; i++)
		{
			fileInfos[i].subDataExchangeId = po.nextSubDataExchangeId();
			fileInfos[i].number = (po.nextSubDataExchangeNumberSeq++);
			fileInfos[i].dependentNumber = "";
			
			po.postBuildSubDataExchange(fileInfos[i]);
		}
		
		po.addRowData(fileInfos);
	};
	
	po.postBuildSubDataExchange = function(subDataExchange){};
	
	po.renderFileNameColumn = function(fileName)
	{
		if(!fileName)
			return "";
		
		if(fileName.length <= 10 + 3 + 20)
			return fileName;
		
		return "<span title='"+$.escapeHtml(fileName)+"'>" + fileName.substr(0, 10) + "..." + fileName.substr(fileName.length - 20) +"</span>";
	};
	
	po.dataImportTableColumns =
	[
		{
			title : "<@spring.message code='dataImport.number' />",
			data : "number",
			render : function(data, type, row, meta)
			{
				return $.escapeHtml(data) + "<input type='hidden' name='numbers[]' value='"+$.escapeHtml(data)+"' class='table-number-input ui-widget ui-widget-content ui-corner-all' style='width:90%' />";
			},
			defaultContent: "",
			width : "10%"
		},
		{
			title : "<@spring.message code='dataImport.importFileName' />",
			data : "displayName",
			render : function(data, type, row, meta)
			{
				return po.renderFileNameColumn(data)
					+ "<input type='hidden' name='subDataExchangeIds[]' value='"+$.escapeHtml(row.subDataExchangeId)+"' />"
					+ "<input type='hidden' name='fileNames[]' value='"+$.escapeHtml(row.name)+"' />";
			},
			defaultContent: "",
			width : "45%",
		},
		{
			title : "<@spring.message code='dataImport.importFileSize' />",
			data : "size",
			render : po.renderColumn,
			defaultContent: "",
			width : "10%"
		},
		{
			title : "<@spring.message code='dataImport.dependentNumber' />",
			data : "dependentNumber",
			render : function(data, type, row, meta)
			{
				return "<input type='text' name='dependentNumbers[]' value='"+$.escapeHtml(data)+"' "
						+ (po.dependentNumberInputPlaceholder ? "placeholder='"+$.escapeHtml(po.dependentNumberInputPlaceholder)+"'" : "")
						+ " class='table-dependent-number-input ui-widget ui-widget-content ui-corner-all' style='width:90%' />";
			},
			defaultContent: "",
			width : "10%"
		},
		{
			title : $.buildDataTablesColumnTitleWithTip("<@spring.message code='dataImport.importProgress' />", "<@spring.message code='dataImport.importStatusWithSuccessFail' />"),
			data : "status",
			render : function(data, type, row, meta)
			{
				if(!data)
					return "<@spring.message code='dataExchange.exchangeStatus.Unstart' />";
				else
					return data;
			},
			defaultContent: "",
			width : "25%"
		}
	];

	po.onStepChanged = function(event, currentIndex, priorIndex)
	{
		if(currentIndex == 1)
			po.adjustDataTable();
	};
	
	po.initDataImportSteps = function()
	{
		po.element(".form-content").steps(
		{
			headerTag: "h3",
			bodyTag: "div",
			onStepChanged : function(event, currentIndex, priorIndex)
			{
				po.onStepChanged(event, currentIndex, priorIndex);
			},
			onFinished : function(event, currentIndex)
			{
				po.form().submit();
			},
			labels:
			{
				previous: "<@spring.message code='wizard.previous' />",
				next: "<@spring.message code='wizard.next' />",
				finish: "<@spring.message code='import' />"
			}
		});
		
		po.element(".wizard .actions ul li:eq(2)", po.form()).addClass("page-status-aware-enable edit-status-enable");
	};
	
	po.initDataImportUIs = function()
	{
		po.initFormBtns();
		po.elementOfId("${pageId}-exceptionResolve").checkboxradiogroup();
		po.elementOfName("fileEncoding").selectmenu({ appendTo : po.element(), classes : { "ui-selectmenu-menu" : "file-encoding-selectmenu-menu" } });
		po.elementOfName("zipFileNameEncoding").selectmenu({ appendTo : po.element(), classes : { "ui-selectmenu-menu" : "file-encoding-selectmenu-menu" } });
		
		po.elementOfId("${pageId}-exceptionResolve-0").click();
	};
	
	po.initDataImportDataTable = function()
	{
		var tableSettings = po.buildLocalTableSettings(po.dataImportTableColumns, [], {"order": []});
		
		po.subDataExchangeStatusColumnIndex = tableSettings.columns.length - 1;
		
		po.initTable(tableSettings);
		
		po.table().on("click", ".table-dependent-number-input", function(event)
		{
			//阻止行选中
			event.stopPropagation();
		});
	};
	
	po.initDataImportActions = function()
	{
		var uploadAction = po.element(".fileinput-button").attr("upload-action");
		po.element(".uploadFileWrapper").fileUpload("${contextPath}/dataexchange/" + po.schemaId +"/import/" + uploadAction,
		{
			success: function(response)
			{
				po.addSubDataExchangesForFileInfos(response);
			}
		});
		
		po.element(".table-delete-item-button").click(function()
		{
			po.executeOnSelects(function()
			{
				po.deleteSelectedRows();
			});
		});
		
		po.element(".table-cancel-import-button").click(function()
		{
			po.cancelSelectedSubDataExchange();
		});
		
		po.element(".restart-button").click(function()
		{
			po.updateDataExchangePageStatus("edit");
		});
		
		po.table().on("click", ".exchange-result-icon", function(event)
		{
			//阻止行选中
			event.stopPropagation();
			
			var $this = $(this);
			
			if($this.hasClass("exchange-error-icon"))
			{
				var subDataExchangeId = $this.attr("subDataExchangeId");
				po.viewSubDataExchangeDetailLog(subDataExchangeId);
			}
		});
		
		po.form().submit(function()
		{
			if(po.dataExchangeTaskClient.isActive())
				return;
			
			po.dataExchangeTaskClient.start();
			po.resetAllSubDataExchangeStatus();
			
			$(this).ajaxSubmitJson(
			{
				success: function()
				{
					if(!po.isDataExchangePageStatus("finish"))
						po.updateDataExchangePageStatus("exchange");
				},
				error: function()
				{
					po.dataExchangeTaskClient.stop();
				}
			});
			
			return false;
		});
	};
})
(${pageId});
</script>
</body>
</html>
