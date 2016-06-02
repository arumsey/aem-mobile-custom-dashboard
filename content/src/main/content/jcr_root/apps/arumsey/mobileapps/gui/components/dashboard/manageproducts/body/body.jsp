<%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page session="false"
           import="com.adobe.granite.ui.components.AttrBuilder,
                   com.adobe.granite.ui.components.ComponentHelper,
                   com.adobe.granite.ui.components.Tag,
                   org.apache.sling.api.resource.Resource,
                   org.apache.sling.api.resource.ValueMap,
                   java.util.Iterator" %><%
%><ui:includeClientLib categories="cq.apps.dashboard.manageproducts,we-healthcare-sales-app.stats"/><%

    String suffix = slingRequest.getRequestPathInfo().getSuffix();
    Resource appResourceContent = resourceResolver.getResource(suffix + "/jcr:content");
    ValueMap vm = appResourceContent.getValueMap();
    String projectId = vm.get("dps-projectId", String.class);
    String cloudConfig = vm.get("dps-cloudConfig", String.class);

    Tag tag = cmp.consumeTag();
    tag.setName("div");
    AttrBuilder attrs = tag.getAttrs();
    attrs.addClass("cq-apps-CardDashboard-body");

    String bodyMessage = i18n.get("Import or Update Product data using this Tile's Actions.");
    if (projectId == null || cloudConfig == null) {
        bodyMessage = i18n.get("Configure a connection to manage the products.");
    }

    tag.printlnStart(out);
%>
<div class="adobecares-manage-product-message">
    <we-product emptyText="<%=bodyMessage%>"></we-product>
</div>
<%
    tag.printlnEnd(out);

    // include any content that the modal might need
    Iterator<Resource> modalIterator = resource.listChildren();
    if (modalIterator != null) {
        while (modalIterator.hasNext()) {
            cmp.include(modalIterator.next(), new ComponentHelper.Options());
        }
    }
%>
