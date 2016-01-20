<%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page session="false"
        import="com.adobe.granite.ui.components.ComponentHelper.Options,
                com.adobe.granite.ui.components.Config,
                com.adobe.granite.ui.components.Tag,
                com.adobe.granite.ui.components.Value,
                org.apache.sling.api.resource.Resource,
                java.util.Iterator" %><%
%><ui:includeClientLib categories="custom-tile.tile.upload-data"/><%
    String suffix = slingRequest.getRequestPathInfo().getSuffix();
    Resource appResource = resourceResolver.getResource(suffix);

    Config cfg = new Config(appResource);
    Tag tag = cmp.consumeTag();

    tag.printlnStart(out);
%>
<div class="custom-tile-UploadData">
    <h3>Use this tile to generate articles from uploaded data.</h3>
</div>
<%
    tag.printlnEnd(out);

    // include any content that the modal might need
    try {
        request.setAttribute(Value.CONTENTPATH_ATTRIBUTE, suffix + "/jcr:content");
        Iterator<Resource> modalIterator = resource.listChildren();
        if (modalIterator != null) {
            while (modalIterator.hasNext()) {
                cmp.include(modalIterator.next(), new Options());
            }
        }
    } finally {
        request.removeAttribute(Value.CONTENTPATH_ATTRIBUTE);
    }
%>