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
formAction 表单提交action，允许为null
readonly 是否只读操作，允许为null
-->
<#assign formAction=(formAction!'#')>
<#assign readonly=(readonly!false)>
<html>
<head>
<#include "../include/html_head.ftl">
<title><#include "../include/html_title_app_name.ftl"><@spring.message code='${titleMessageKey}' /></title>
</head>
<body>
<#include "../include/page_obj.ftl" >
<div id="${pageId}" class="schema-form">
	<form id="${pageId}-form" action="${contextPath}/schema/${formAction}" method="POST">
		<div class="form-head"></div>
		<div class="form-content">
			<input type="hidden" name="id" value="${(schema.id)!''}">
			<div class="form-item">
				<div class="form-item-label">
					<label><@spring.message code='schema.title' /></label>
				</div>
				<div class="form-item-value">
					<input type="text" name="title" value="${(schema.title)!''}" required="required" maxlength="100" class="ui-widget ui-widget-content ui-corner-all" autofocus="autofocus" />
				</div>
			</div>
			<div class="form-item">
				<div class="form-item-label">
					<label title="<@spring.message code='schema.url.desc' />">
						<@spring.message code='schema.url' />
					</label>
				</div>
				<div class="form-item-value">
					<input type="text" name="url" value="${(schema.url)!''}" required="required" maxlength="1000" class="ui-widget ui-widget-content ui-corner-all" placeholder="jdbc:" />
					<#if !readonly>
					<button id="schemaBuildUrlHelp" type="button" class="small-button" title="<@spring.message code='schema.urlHelp' />"><span class="ui-icon ui-icon-help"></span></button>
					</#if>
				</div>
			</div>
			<div class="form-item">
				<div class="form-item-label">
					<label><@spring.message code='schema.user' /></label>
				</div>
				<div class="form-item-value">
					<input type="text" name="user" value="${(schema.user)!''}" maxlength="200" class="ui-widget ui-widget-content ui-corner-all" autocomplete="off" />
				</div>
			</div>
			<#if !readonly>
			<div class="form-item">
				<div class="form-item-label">
					<label><@spring.message code='schema.password' /></label>
				</div>
				<div class="form-item-value">
					<input type="password" name="password" value="${(schema.password)!''}" maxlength="100" class="ui-widget ui-widget-content ui-corner-all" autocomplete="new-password" />
				</div>
			</div>
			</#if>
			<#if readonly>
			<div class="form-item">
				<div class="form-item-label">
					<label><@spring.message code='schema.createUser' /></label>
				</div>
				<div class="form-item-value">
					<input type="text" name="user" value="${(schema.createUser.nameLabel)!''}" class="ui-widget ui-widget-content ui-corner-all" />
				</div>
			</div>
			<div class="form-item">
				<div class="form-item-label">
					<label><@spring.message code='schema.createTime' /></label>
				</div>
				<div class="form-item-value">
					<input type="text" name="user" value="${((schema.createTime)?datetime)!''}" class="ui-widget ui-widget-content ui-corner-all" />
				</div>
			</div>
			</#if>
			<#if !readonly>
			<div class="form-item">
				<div class="form-item-label">
					<label><@spring.message code='advancedSetting' /></label>
				</div>
				<div class="form-item-value">
					<button id="schemaAdvancedSet" type="button" style="font-size: 0.8em;">&nbsp;</button>
				</div>
			</div>
			</#if>
			<div class="form-item" id="schemaDriverEntityFormItem">
				<div class="form-item-label">
					<label title="<@spring.message code='schema.driverEntity.desc' />">
						<@spring.message code='schema.driverEntity' />
					</label>
				</div>
				<div id="driverEntityFormItemValue" class="form-item-value">
					<input type="hidden" id="driverEntityId" name="driverEntity.id" value="${(schema.driverEntity.id)!''}" />
					<input type="text" id="driverEntityText" value="${(schema.driverEntity.displayText)!''}" size="20" readonly="readonly" class="ui-widget ui-widget-content ui-corner-all" />
					<#if !readonly>
					<div id="driverEntityActionGroup">
						<button id="driverEntitySelectButton" type="button"><@spring.message code='select' /></button>
						<select id="driverEntityActionSelect">
							<option value='del'><@spring.message code='delete' /></option>
						</select>
					</div>
					</#if>
				</div>
			</div>
			<#if !readonly>
			<div class="form-item">
				<div class="form-item-label">
					&nbsp;
				</div>
				<div class="form-item-value">
					<button class="test-connection-button" type="button"><@spring.message code='schema.testConnection' /></button>
					<span class="test-connection-tip minor" style="display:none;"><@spring.message code='schema.testConnectionTip' /></span>
				</div>
			</div>
			</#if>
		</div>
		<div class="form-foot">
			<#if !readonly>
			<button type="submit" class="recommended"><@spring.message code='save' /></button>
			</#if>
		</div>
	</form>
</div>
<#include "../include/page_obj_form.ftl">
<script type="text/javascript">
(function(po)
{
	po.initFormBtns();
	
	po.driverEntityFormItemValue = function(){ return this.elementOfId("driverEntityFormItemValue"); };
	po.schemaDriverEntityFormItem = function(){ return this.elementOfId("schemaDriverEntityFormItem"); };
	po.isDriverEntityEmpty = (po.elementOfName("driverEntity.id").val() == "");
	
	po.elementOfId("schemaBuildUrlHelp").click(function()
	{
		po.open("${contextPath}/schemaUrlBuilder/buildUrl",
		{
			data : { url : po.elementOfName("url").val() },
			width: "60%",
			pageParam :
			{
				"setSchemaUrl" : function(url)
				{
					po.elementOfName("url").val(url);
				}
			}
		});
	});
	
	po.elementOfId("driverEntitySelectButton").click(function()
	{
		var options =
		{
			pageParam :
			{
				select : function(driverEntity)
				{
					po.elementOfName("driverEntity.id").val(driverEntity.id);
					po.elementOfId("driverEntityText").val(driverEntity.displayText);
				}
			}
		};
		$.setGridPageHeightOption(options);
		po.open("${contextPath}/driverEntity/select", options);
	});
	
	po.elementOfId("driverEntityActionSelect").selectmenu(
	{
		appendTo: po.driverEntityFormItemValue(),
		classes:
		{
	          "ui-selectmenu-button": "ui-button-icon-only splitbutton-select"
	    },
	    select: function(event, ui)
    	{
    		var action = $(ui.item).attr("value");
    		
			if("del" == action)
    		{
				po.elementOfId("driverEntityId").val("");
				po.elementOfId("driverEntityText").val("");
    		}
    	}
	});
	
	po.element(".test-connection-button").click(function()
	{
		po._STATE_TEST_CONNECTION = true;
		po.form().submit();
	});
	
	po.elementOfId("driverEntityActionGroup").controlgroup();
	
	if(po.isDriverEntityEmpty)
		po.schemaDriverEntityFormItem().hide();
	
	po.elementOfId("schemaAdvancedSet").button(
	{
		icon: (po.schemaDriverEntityFormItem().is(":hidden") ? "ui-icon-triangle-1-s" : "ui-icon-triangle-1-n"),
		showLabel: false
	})
	.click(function()
	{
		var item = po.schemaDriverEntityFormItem();
		
		if(item.is(":hidden"))
		{
			item.show();
			$(this).button("option", "icon", "ui-icon-triangle-1-n");
		}
		else
		{
			item.hide();
			$(this).button("option", "icon", "ui-icon-triangle-1-s");
		}
	});
	
	po.originalFormAction = po.form().attr("action");
	
	po.validateAjaxJsonForm({},
	{
		handleData: function()
		{
			if(po._STATE_TEST_CONNECTION == true)
			{
				po.form().attr("action", "${contextPath}/schema/testConnection");
				po.defaultSubmitSuccessBak = po.defaultSubmitSuccess;
				po.defaultSubmitSuccess = null;
			}
		},
		beforeSend: function()
		{
			if(po._STATE_TEST_CONNECTION == true)
			{
				po.element(".test-connection-button, [type='submit']").addClass("ui-state-disabled");
				po.element(".test-connection-tip").show();
			}
		},
		complete: function()
		{
			if(po._STATE_TEST_CONNECTION == true)
			{
				po.form().attr("action", po.originalFormAction);
				po.defaultSubmitSuccess = po.defaultSubmitSuccessBak;
				po._STATE_TEST_CONNECTION = false;
				po.element(".test-connection-button, [type='submit']").removeClass("ui-state-disabled");
				po.element(".test-connection-tip").hide();
			}
		}
	});
})
(${pageId});
</script>
</body>
</html>