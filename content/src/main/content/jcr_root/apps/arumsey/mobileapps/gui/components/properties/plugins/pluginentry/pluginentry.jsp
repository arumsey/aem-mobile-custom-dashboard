<%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page import="com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.ui.components.Config,
				  com.adobe.granite.ui.components.Tag, org.apache.sling.api.resource.ValueMap"%><%
%><%

	Config cfg = new Config(resource);
	Tag tag = cmp.consumeTag();
	AttrBuilder attrs = tag.getAttrs();
    attrs.addClass("coral-Form-fieldset");

	ValueMap map = resource.getValueMap();
	final String specName = "widget/plugins/" + map.get("name") + "/spec";
	final String spec = map.get("spec", "");

%><section <%= attrs.build() %>>
        <div class="coral-Form-fieldwrapper">
            <label class="coral-Form-fieldlabel">Spec</label>
            <input class="coral-Form-field coral-Textfield" name="<%= xssAPI.encodeForHTMLAttr(specName) %>" value="<%= xssAPI.encodeForHTMLAttr(spec) %>">
            <span class="coral-Form-fieldinfo coral-Icon coral-Icon--infoCircle coral-Icon--sizeS" data-init="quicktip" data-quicktip-type="info" data-quicktip-arrow="right" data-quicktip-content="<%= xssAPI.encodeForHTMLAttr("Details about the plugin to be restored. This could be a major.minor.patch version number, a directory containing the plugin or a url pointing to a git repository.") %>"></span>
        </div>
</section>
