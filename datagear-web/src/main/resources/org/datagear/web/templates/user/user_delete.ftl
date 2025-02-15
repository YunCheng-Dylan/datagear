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
-->
<#assign formAction=(formAction!'#')>
<html>
<head>
<#include "../include/html_head.ftl">
<title><#include "../include/html_title_app_name.ftl"><@spring.message code='${titleMessageKey}' /></title>
</head>
<body>
<#include "../include/page_obj.ftl" >
<div id="${pageId}" class="page-form page-form-user-delete">
	<form id="${pageId}-form" action="${contextPath}/user/${formAction}" method="POST">
		<div class="form-head"></div>
		<div class="form-content">
			<div class="form-item">
				<div class="form-item-label">
					<label><@spring.message code='user.name' /></label>
				</div>
				<div class="form-item-value">
					<div class="delete-users ui-widget ui-widget-content ui-corner-all input minor-list deletable-list">
					</div>
					<input type="text" name="deleteUserPlaceholder" style="display:none;" />
				</div>
			</div>
			<div class="form-item">
				<div class="form-item-label">
					<label title="<@spring.message code='user.migrateDataToUser.desc' />">
						<@spring.message code='user.migrateDataToUser' />
					</label>
				</div>
				<div class="form-item-value">
					<input type="text" name="migrateUserName" value="" required="required" maxlength="50" class="ui-widget ui-widget-content ui-corner-all" readonly="readonly" />
					<input type="hidden" name="migrateToId" value="" />
					<button class="selectUserBtn" type="button"><@spring.message code='select' /></button>
				</div>
			</div>
		</div>
		<div class="form-foot">
			<button type="submit" class="danger"><@spring.message code='delete' /></button>
		</div>
	</form>
</div>
<#include "../include/page_obj_form.ftl">
<script type="text/javascript">
(function(po)
{
	po.deleteUsers = <@writeJson var=deleteUsers />;
	
	po.initFormBtns();
	
	po.url = function(action)
	{
		return "${contextPath}/user/" + action;
	};
	
	po.element(".delete-users").on("click", ".delete-icon", function()
	{
		$(this).closest(".minor-list-item").remove();
	});
	
	po.renderUsers = function(roles)
	{
		roles = (roles || []);
		var $parent = po.element(".delete-users");
		
		for(var i=0; i<roles.length; i++)
			po.renderUser($parent, roles[i]);
	}
	
	po.renderUser = function($parent, user)
	{
		var $item = $("<div class='minor-list-item ui-widget ui-widget-content ui-corner-all' />").appendTo($parent);
		$("<input type='hidden' class='deleteUserIds' name='ids[]' />").attr("value", user.id).appendTo($item);
		
		$("<span class='delete-icon ui-icon ui-icon-close' title='<@spring.message code='delete' />' />").appendTo($item);
		
		$("<div class='item-content' />").text(user.nameLabel).appendTo($item);
	};
	
	po.element(".selectUserBtn").click(function()
	{
		var options =
		{
			pageParam :
			{
				select : function(user)
				{
					po.elementOfName("migrateToId").val(user.id);
					po.elementOfName("migrateUserName").val(user.nameLabel);
				}
			}
		};
		
		$.setGridPageHeightOption(options);
		
		po.open("${contextPath}/user/select", options);
	});
	
	$.validator.addMethod("deleteUserIdRequired", function(value, element)
	{
		var $du = po.element(".deleteUserIds");
		return ($du.length > 0);
	});
	
	$.validator.addMethod("migrateToUserIdIllegal", function(value, element)
	{
		var $du = po.element(".deleteUserIds");
		var mu = po.elementOfName("migrateToId").val();
		
		for(var i=0; i<$du.length; i++)
		{
			if(mu == $($du[i]).val())
				return false;
		}
		
		return true;
	});
	
	po.validateAjaxJsonForm(
	{
		ignore : "",
		rules :
		{
			deleteUserPlaceholder : "deleteUserIdRequired",
			migrateUserName : { "migrateToUserIdIllegal": true }
		},
		messages :
		{
			deleteUserPlaceholder : po.validateMessages.required,
			migrateUserName :
			{
				"migrateToUserIdIllegal": "<@spring.message code='user.validation.migrateToUserIdIllegal' />"
			}
		}
	},
	{
		ignore: ["deleteUserPlaceholder", "migrateUserName"]
	});
	
	po.renderUsers(po.deleteUsers);
})
(${pageId});
</script>
</body>
</html>