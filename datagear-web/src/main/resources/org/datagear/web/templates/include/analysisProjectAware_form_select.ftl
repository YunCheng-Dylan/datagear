<#--
 *
 * Copyright 2018 datagear.tech
 *
 * Licensed under the LGPLv3 license:
 * http://www.gnu.org/licenses/lgpl-3.0.html
 *
-->
<#--
数据分析项目相关表单页：所属数据分析项目选择框
-->
<div class="form-item-analysisProject form-item">
	<div class="form-item-value">
		<input type="text" name="analysisProject.name" value="" placeholder="<@spring.message code='analysisProject.ownerAnalysisProject' />" class="width-7 ui-widget ui-widget-content ui-corner-all" readonly="readonly" />
		<input type="hidden" name="analysisProject.id" value="" />
		<#if !readonly>
		<ul class="analysisProjectActionSelect lightweight-menu">
			<li class="analysis-project-menu-root">
				<div><span class="ui-icon ui-icon-triangle-1-s"></span> </div>
				<ul class="ui-widget-shadow">
					<li value='select'><a href="javascript:void(0);"><@spring.message code='select' /></a></li>
					<li value='del'><a href="javascript:void(0);"><@spring.message code='delete' /></a></li>
				</ul>
			</li>
		</ul>
		</#if>
	</div>
</div>
<script type="text/javascript">
(function(po)
{
	po.initAnalysisProject = function(id, name)
	{
		po.elementOfName("analysisProject.id").attr("value", id || "");
		po.elementOfName("analysisProject.name").attr("value", name || "");
		
		po.element(".analysisProjectActionSelect").menu(
		{
			appendTo: po.element(),
			position : {my:"right top", at: "right bottom+2"},
		    select: function(event, ui)
	    	{
	    		var action = $(ui.item).attr("value");
	    		
				if("select" == action)
				{
					var options =
					{
						pageParam :
						{
							select : function(analysisProject)
							{
								po.elementOfName("analysisProject.id").val(analysisProject.id);
								po.elementOfName("analysisProject.name").val(analysisProject.name);
							}
						}
					};
					
					$.setGridPageHeightOption(options);
					
					po.open("${contextPath}/analysisProject/select", options);
				}
				else if("del" == action)
	    		{
					po.elementOfName("analysisProject.id").val("");
					po.elementOfName("analysisProject.name").val("");
	    		}
	    	}
		});
	};
})
(${pageId});
</script>