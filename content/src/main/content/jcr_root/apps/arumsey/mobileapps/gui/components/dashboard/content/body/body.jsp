<%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page session="false"
        import="com.adobe.granite.ui.components.AttrBuilder,
                com.adobe.granite.ui.components.Config,
                com.adobe.granite.ui.components.Tag,
                com.adobe.granite.ui.components.ExpressionHelper" %><%
%><ui:includeClientLib categories="arumsey.apps.dashboard.content"/><%

    Config cfg = new Config(resource);
    final ExpressionHelper ex = cmp.getExpressionHelper();

    String bodyMessage = i18n.get("No Content");
    final String feedPath = cmp.getExpressionHelper().getString(cfg.get("feedPath", String.class));

    Tag tag = cmp.consumeTag();
    AttrBuilder attrs = tag.getAttrs();
    attrs.addHref("data-feed-href", resource.getPath() + ".status.json" + feedPath);

    tag.printlnStart(out);

%>
<ar-status emptyText="<%=bodyMessage%>"></ar-status>
<%
    tag.printlnEnd(out);
%>