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
<html>
<head>
<#include "../include/html_head.ftl">
<title><#include "../include/html_title_app_name.ftl"><@spring.message code='driverEntity.importDriverEntity' /></title>
</head>
<body>
<#include "../include/page_obj.ftl" >
<div id="${pageId}" class="page-form page-form-driverEntityImport">
	<form id="${pageId}-form" action="${contextPath}/driverEntity/saveImport" method="POST">
		<div class="form-head"></div>
		<div class="form-content">
			<input type="hidden" name="importId" value="${importId}" />
			<div class="form-item">
				<div class="form-item-label">
					<label><@spring.message code='driverEntity.import.selectFile' /></label>
				</div>
				<div class="form-item-value">
					<div class="driver-import-parent">
						<div class="fileinput-button button"><@spring.message code='select' /><input type="file" accept=".zip" class="ignore"></div>
						<div class="upload-file-info"></div>
					</div>
				</div>
			</div>
			<div class="form-item">
				<div class="form-item-label">
					<label><@spring.message code='driverEntity.import.review' /></label>
				</div>
				<div class="form-item-value">
					<input type="hidden" name="inputForValidate" value="" />
					<div class="driver-entity-infos minor-list deletable-list input ui-widget ui-widget-content ui-corner-all"></div>
				</div>
			</div>
		</div>
		<div class="form-foot">
			<button type="submit" class="recommended"><@spring.message code='import' /></button>
		</div>
	</form>
</div>
<#include "../include/page_obj_form.ftl">
<script type="text/javascript">
(function(po)
{
	po.initFormBtns();
	
	po.driverEntityInfos = function(){ return this.element(".driver-entity-infos"); };

	po.url = function(action)
	{
		return "${contextPath}/driverEntity/" + action;
	};
	
	po.renderDriverEntityInfos = function(driverEntities)
	{
		po.driverEntityInfos().empty();
		
		for(var i=0; i<driverEntities.length; i++)
		{
			var driverEntity = driverEntities[i];
			
			var $item = $("<div class='driver-entity-item minor-list-item ui-widget ui-widget-content ui-corner-all' />")
				.appendTo(po.driverEntityInfos());
			
			$("<input type='hidden' />").attr("name", "driverEntityIds[]").attr("value", driverEntity.id).appendTo($item);
			
			$("<span class='delete-icon ui-icon ui-icon-close' title='<@spring.message code='delete' />' />")
			.appendTo($item).click(function()
			{
				$(this).closest(".driver-entity-item").remove();
			});
			
			var content = driverEntity.displayText;
			$("<span class='driver-entity-info item-content' />").attr("title", content).text(content)
			.appendTo($item);
		}
	};

	po.element(".driver-import-parent").fileUpload(po.url("uploadImportFile"),
	{
		success: function(response)
		{
			po.renderDriverEntityInfos(response);
		}
	});
	
	$.validator.addMethod("importDriverEntityRequired", function(value, element)
	{
		var $driverEntityId = po.elementOfName("driverEntityIds[]");
		return $driverEntityId.length > 0;
	});
	
	po.validateAjaxJsonForm(
	{
		ignore : ".ignore",
		rules :
		{
			inputForValidate : "importDriverEntityRequired"
		},
		messages :
		{
			inputForValidate : "<@spring.message code='driverEntity.import.importDriverEntityRequired' />"
		}
	},
	{
		ignore: "inputForValidate",
	});
})
(${pageId});
</script>
</body>
</html>