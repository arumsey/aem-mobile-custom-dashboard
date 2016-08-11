<%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page session="false"
        import="com.adobe.cq.mobile.platform.MobileResource,
                com.adobe.cq.mobile.platform.MobileResourceType,
                com.adobe.cq.mobile.ui.AppCacheDataSource,
                com.adobe.granite.ui.components.AttrBuilder,
                com.adobe.granite.ui.components.Config,
                com.adobe.granite.ui.components.Tag,
                com.adobe.granite.ui.components.ds.DataSource,
                com.day.cq.wcm.api.Page,
                org.apache.sling.api.resource.ValueMap,
                org.apache.sling.commons.json.JSONObject,
                org.apache.sling.api.resource.Resource,
                java.util.Iterator" %><%
%><ui:includeClientLib categories="cq.apps.dashboard.content"/><%

    String suffix = slingRequest.getRequestPathInfo().getSuffix();
    Resource appResource = resourceResolver.getResource(suffix);

    Config cfg = new Config(resource);
    Config appCfg = new Config(appResource);
    DataSource ds = cmp.getItemDataSource();

    int maxNumberOfRows = cfg.get("maxBodyTableRows", Integer.MAX_VALUE);
    String xssContentHRefTarget = xssAPI.encodeForHTMLAttr(cfg.get("contentTagName", "appcontent"));

    Tag tag = cmp.consumeTag();
    AttrBuilder attrs = tag.getAttrs();
    attrs.addClass("cq-apps-DashboardTable");
    attrs.addOthers(appCfg.getProperties(), "class");

    tag.printlnStart(out);%>
<table class="cq-apps-Content">
    <tbody>
    <tr>
        <th></th><%--Blank column for the icon--%>
        <th class="title"><%= i18n.get("Title")%></th>
        <th class="pages"><%= i18n.get("Files")%></th>
        <th class="modified"><%= i18n.get("Modified")%></th>
    </tr><%
Iterator<Resource> iterator = ds.iterator();
int i = 0;
boolean firstLoop = true;
while (iterator.hasNext()) {
    if (i >= maxNumberOfRows) {
        break;
    }

    Resource r = iterator.next();

    boolean pendingChanges = false;

    MobileResource appContent = r.adaptTo(MobileResource.class);
    boolean isInstance = appContent.isA(MobileResourceType.INSTANCE.getType());
    AppCacheDataSource appCacheDataSource = appContent.adaptTo(AppCacheDataSource.class);
    long stagedDate = 0L;
    try {
        JSONObject json = appCacheDataSource.getCacheUpdates();
        stagedDate = getKeyForLong(json, "lastUpdated");
    } catch(Exception ex) {
        stagedDate = 0L;
    }

%><sling:include path="<%= r.getPath() %>" resourceType="mobileapps/gui/components/contentpackage" replaceSelectors="init"/><%
    ValueMap map = (ValueMap) request.getAttribute("content-item");
    if (map == null) {
        continue;
    }
    final String xssItemHRef = xssAPI.getValidHref(request.getContextPath() + map.get("itemHref", ""));
    final String xssImageUrl = xssAPI.getValidHref(request.getContextPath() + map.get("imageUrl", ""));
    final String xssTitle = xssAPI.encodeForHTML(map.get("title", ""));
    final String xssDescription = xssAPI.encodeForHTML(map.get("description", ""));
    final String xssLastModified = xssAPI.encodeForHTML(map.get("lastModified", ""));
    final String xssLastModifiedBy = xssAPI.encodeForHTML(map.get("lastModifiedBy", ""));
    final String xssChildResourceCount = xssAPI.encodeForHTML(map.get("childResourceCount", ""));

    Page pageItem = r.adaptTo(Page.class);
    if (pageItem != null) {
        long lastTime = map.get("lastTime", 0L);
        if (lastTime > 0) {
            pendingChanges = areChangesPending(stagedDate, lastTime);
        }
    }

    // Show the content packages that have changes pending first (first one is shell package).
    if (i != 0 && firstLoop != pendingChanges) {
        // First loop is done (shell & pending changes), loop again displaying
        // 'up to date' content packages only (skip shell package - 1st element)
        if (firstLoop && !iterator.hasNext()) {
            firstLoop = false;
            iterator = ds.iterator();
            // Skip first one (it is the shell)
            iterator.next();
        }
        continue;
    }
    i++;


    %><tr class="cq-apps-clickable-row" data-href="<%= xssItemHRef %>" data-href-tabname="<%= xssContentHRefTarget %>">
        <td><%
            if (isInstance) {%>
            <i class="coral-Icon coral-Icon--app coral-Icon--sizeS"></i>
            <% }
            else {
            %><img class="cq-apps-Content-pageImage" alt="" src="<%= xssImageUrl %>"><%
            }%>
        </td>
        <td class="title">
            <span>
                <div class="title"><%= xssTitle %></div><%
                if (xssDescription != null && !xssDescription.isEmpty()) {%>
                    <span class="subtext cq-apps-content-description"><%= xssDescription %></span><%
                }%>
            </span>
        </td>
        <td class="pages">
            <span><%= xssChildResourceCount %></span>
        </td>
        <td class="modified">
            <span class="cq-apps-Content-infoBox">
                <time><%= xssLastModified %></time><%
                if (!xssLastModifiedBy.isEmpty()) {
                %>
                <span class="cq-apps-Content--author"><%= xssLastModifiedBy %></span><%
                }
                %>
            </span>
        </td>
    </tr>
<%
        // First loop is done (shell & pending changes), loop again displaying
        // 'up to date' content packages only (skip shell package - 1st element)
        if (firstLoop && !iterator.hasNext()) {
            firstLoop = false;
            iterator = ds.iterator();
            iterator.next();
        }
    } %>
    </tbody>
</table><%
    tag.printlnEnd(out);
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
%>
