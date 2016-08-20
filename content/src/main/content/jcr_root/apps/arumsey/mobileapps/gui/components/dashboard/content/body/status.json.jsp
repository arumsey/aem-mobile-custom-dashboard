<%@ page session="false"
         import="com.adobe.cq.mobile.ui.AppCacheDataSource,
        com.adobe.granite.ui.components.ds.DataSource,
        com.day.cq.commons.LabeledResource,
        com.day.cq.commons.TidyJSONWriter,
        com.day.cq.commons.date.RelativeTimeFormat,
        org.apache.sling.commons.json.JSONException,
        org.apache.sling.commons.json.JSONObject,
        java.util.ResourceBundle,
        com.day.cq.i18n.I18n"%><%
%><%@include file="/libs/foundation/global.jsp" %><%
%><%@include file="/libs/mobileapps/gui/components/mostrecentlymodified/mostrecentlymodified.jsp" %><%

    response.setContentType("application/json");
    response.setCharacterEncoding("utf-8");

    //
    // Return app status as JSON data
    //
    I18n i18n = new I18n(slingRequest);
    ResourceBundle resourceBundle = slingRequest.getResourceBundle(slingRequest.getLocale());
    RelativeTimeFormat rtf = new RelativeTimeFormat("r", resourceBundle);

    TidyJSONWriter writer = new TidyJSONWriter(response.getWriter());
    writer.setTidy(true);

    try {
        writer.object();

%><cq:include script="/libs/mobileapps/gui/components/datasources/contentdatasource/contentdatasource.jsp"/><%

        DataSource ds = (DataSource) request.getAttribute(DataSource.class.getName());
        if (ds != null) {

            Iterator<Resource> iterator = ds.iterator();
            int i = 0;
            boolean firstLoop = true;

            while (iterator.hasNext()) {
                Resource r = iterator.next();
                LabeledResource labeledRes = r.adaptTo(LabeledResource.class);

                writer.key(r.getName()).object();
                writer.key("title").value(labeledRes.getTitle());

                boolean pendingChanges = false;

                MobileResource appContent = r.adaptTo(MobileResource.class);
                AppCacheDataSource appCacheDataSource = appContent.adaptTo(AppCacheDataSource.class);
                long stagedDate = 0L;
                try {
                    JSONObject json = appCacheDataSource.getCacheUpdates();
                    stagedDate = getKeyForLong(json, "lastUpdated");
                } catch (Exception ex) {
                    stagedDate = 0L;
                }

                final Node node = ((Resource)r).adaptTo(Node.class);
                if (node.getPrimaryNodeType().isNodeType("cq:Page")) {

                    writer.key("type").value("pages");
                    writer.key("childResourceCount").value(getNumberOfChildResources(r, "cq:PageContent"));

                    long lastTime = 0l;
                    Resource lastModifiedResource = getLastModifiedPage(r);
                    if (lastModifiedResource != null) {
                        ValueMap lastModifiedResourceVM = lastModifiedResource.getValueMap();
                        lastTime = lastModifiedResourceVM.get("cq:lastModified", 0l);
                        writer.key("lastModifiedTime").value(lastTime);
                        writer.key("lastModified").value(i18n.getVar(rtf.format(lastTime, true)));
                        writer.key("hasPendingChanges").value(areChangesPending(stagedDate, lastTime));
                    }

                } else if (node.getPrimaryNodeType().isNodeType("sling:OrderedFolder") ||
                        node.getPrimaryNodeType().isNodeType("sling:Folder")) {

                    writer.key("type").value("app");
                    writer.key("childResourceCount").value(getNumberOfChildResources(r, "dam:AssetContent"));

                    long lastTime = 0l;
                    Resource lastModifiedResource = getLastModifiedResource(r, "dam:AssetContent", "jcr:lastModified");
                    if (lastModifiedResource != null) {
                        ValueMap lastModifiedResourceVM = lastModifiedResource.getValueMap();
                        lastTime = lastModifiedResourceVM.get("jcr:lastModified", 0l);
                        writer.key("lastModifiedTime").value(lastTime);
                        writer.key("lastModified").value(i18n.getVar(rtf.format(lastTime, true)));
                    }

                }

                writer.endObject();

            }
        }

        writer.endObject();

    } catch (JSONException e) {
        log.error("Unable to write content status", e);
    }

    response.flushBuffer();

%><%!

    private boolean areChangesPending(long lastCSUpdated, long lastAppUpdateModification) {
        boolean pendingChanges = false;
        if (lastAppUpdateModification != 0) {
            if (lastCSUpdated < lastAppUpdateModification) {
                pendingChanges = true;
            }
        }

        return pendingChanges;
    }

    private long getKeyForLong(JSONObject json, String key) {
        try {
            if (json.has(key)) {
                return json.getLong(key);
            }
        } catch(Exception ex) {
            return 0;
        }
        return 0;
    }

    private int getNumberOfChildResources(Resource resource, String resourceType) {
        ResourceResolver resolver = resource.getResourceResolver();

        Map<String, String> map = new HashMap<String, String>();
        map.put("path", resource.getPath());
        map.put("type", resourceType);
        map.put("p.offset", "0");
        map.put("p.limit", "-1");

        QueryBuilder queryBuilder = resolver.adaptTo(QueryBuilder.class);
        Query query = queryBuilder.createQuery(PredicateGroup.create(map), resolver.adaptTo(Session.class));
        SearchResult searchResult = query.getResult();
        return searchResult.getHits().size();
    }
%>