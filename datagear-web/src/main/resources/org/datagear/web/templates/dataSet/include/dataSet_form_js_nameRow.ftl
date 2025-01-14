<#--
 *
 * Copyright 2018 datagear.tech
 *
 * Licensed under the LGPLv3 license:
 * http://www.gnu.org/licenses/lgpl-3.0.html
 *
-->
<#--
数据集表单页：标题行操作JS片段

依赖：
page_obj.ftl

变量：
-->
<script type="text/javascript">
(function(po)
{
	po.initNameRowOperation = function(initValue, noneValue, minAssignValue)
	{
		if(initValue == null)
			initValue = 1;
		if(noneValue == null)
			noneValue = 0;
		if(minAssignValue == null)
			minAssignValue = 1;
		
		po.elementOfName("nameRowRadio").on("change", function()
		{
			var radioVal = $(this).val();
			var $nameRow = po.elementOfName("nameRow");
			var $nameRowText = po.elementOfName("nameRowText");
			
			if(radioVal == (noneValue+""))
			{
				$nameRow.val(noneValue+"");
				$nameRowText.hide();
			}
			else
			{
				var myVal = parseInt($nameRowText.val());
				if(!myVal || myVal < minAssignValue)
					$nameRowText.val(minAssignValue+"");
				
				$nameRowText.show();
			}
		});
		
		po.nameRowValue = function(value)
		{
			var $nameRow = po.elementOfName("nameRow");
			var $nameRowText = po.elementOfName("nameRowText");
			
			if(value === undefined)
			{
				var radioVal = po.element("[name='nameRowRadio']:checked").val();
				
				if(radioVal == (noneValue+""))
					return $nameRow.val();
				else
					return $nameRowText.val();
			}
			else
			{
				$nameRow.val(value);
				$nameRowText.val(value);
				
				po.element("[name='nameRowRadio'][value='"+(value >= minAssignValue ? minAssignValue : noneValue)+"']")
					.attr("checked", "checked").change();
			}
		};
		
		po.nameRowValue(initValue);
	};
})
(${pageId});
</script>