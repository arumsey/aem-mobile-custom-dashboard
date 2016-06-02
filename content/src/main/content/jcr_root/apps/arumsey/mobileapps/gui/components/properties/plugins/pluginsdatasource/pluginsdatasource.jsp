<%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page import="com.adobe.cq.mobile.platform.MobileResource,
                com.adobe.granite.ui.components.Config,
                com.adobe.granite.ui.components.ds.DataSource,
                com.adobe.granite.ui.components.ds.EmptyDataSource,
                com.adobe.granite.ui.components.ds.SimpleDataSource,
                com.adobe.granite.ui.components.ds.ValueMapResource,
                com.day.cq.commons.jcr.JcrConstants,
                org.apache.sling.api.resource.Resource,
                org.apache.sling.api.wrappers.ValueMapDecorator,
                java.util.ArrayList,
                java.util.List,
                java.util.Map" %><%
%><%

    Config cfg = new Config(resource.getChild(Config.DATASOURCE));
    final String itemRT = cfg.get("itemResourceType", String.class);

    String appPath = cmp.getExpressionHelper().getString(cfg.get("resource", String.class));
    appPath = appPath.endsWith(JcrConstants.JCR_CONTENT) ? appPath.substring(0, appPath.length() - JcrConstants.JCR_CONTENT.length() - 1) : appPath;
    final Resource appResource = resourceResolver.getResource(appPath);

    DataSource ds;
    if (appResource == null) {
        ds = EmptyDataSource.instance();
    } else {
        ArrayList<Resource> appPlugins = new ArrayList<Resource>();

        final MobileResource mobileResource = appResource.adaptTo(MobileResource.class);
        final List<Map<String,Object>> pluginList = mobileResource.getProperties().get("widget/plugins", List.class);
        for (Map<String,Object> plugin : pluginList) {
            plugin.put("jcr:title", plugin.get("name"));
            ValueMapResource syntheticResource = new ValueMapResource(resourceResolver, "/synthetic", itemRT, new ValueMapDecorator(plugin));
            appPlugins.add(syntheticResource);
        }

        if (appPlugins.size() == 0) {
            // return empty datasource
            ds = EmptyDataSource.instance();
        } else {
            // create a new datasource object
            ds = new SimpleDataSource(appPlugins    .iterator());
        }

    }

    request.setAttribute(DataSource.class.getName(), ds);
%>