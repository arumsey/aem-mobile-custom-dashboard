<%@include file="/libs/granite/ui/global.jsp" %><%
%><%@page session="false"
          import="com.adobe.cq.mobile.platform.MobileResource,
                  com.adobe.cq.mobile.platform.MobileResourceLocator,
                  com.adobe.cq.mobile.platform.MobileResourceType,
                  com.adobe.granite.security.user.util.AuthorizableUtil,
                  com.adobe.granite.ui.components.AttrBuilder,
                  com.adobe.granite.xss.XSSAPI,
                  com.day.cq.commons.date.RelativeTimeFormat,
                  com.day.cq.commons.jcr.JcrConstants,
                  com.day.cq.wcm.api.Page,
                  com.day.jcr.vault.util.Text,
                  org.apache.commons.lang3.StringUtils,
                  org.apache.sling.api.resource.Resource,
                  org.apache.sling.api.resource.ValueMap,
                  org.slf4j.Logger,
                  javax.jcr.RepositoryException,
                  javax.jcr.Session,
                  javax.jcr.security.AccessControlManager,
                  javax.jcr.security.Privilege,
                  java.util.ArrayList,
                  java.util.Calendar,
                  java.util.List,
                  java.util.ResourceBundle, com.day.cq.wcm.mobile.api.MobileConstants, com.day.cq.dam.api.Asset, java.io.InputStream, org.w3c.dom.Document, javax.xml.parsers.DocumentBuilderFactory, javax.xml.parsers.DocumentBuilder, org.w3c.dom.Element, org.w3c.dom.NodeList"%><%

    Page pageResource = resource.adaptTo(Page.class);

    // It has to be a page.
    if (pageResource == null) {
        return;
    }

    final MobileResource appInstance = resource.adaptTo(MobileResource.class);
    final MobileResourceLocator locator = resourceResolver.adaptTo(MobileResourceLocator.class);
    final MobileResource group = locator.findClosestResourceByType(resource, MobileResourceType.GROUP.getType());

    // Use group page for modified properties if one can be found
    Page groupPage = null;
    if (group != null) {
        groupPage = group.adaptTo(Page.class);
    }
    if (groupPage == null) {
        groupPage = pageResource;
    }

    ResourceBundle rb = slingRequest.getResourceBundle(slingRequest.getLocale());
    RelativeTimeFormat rtf = new RelativeTimeFormat("r", rb);

    String xssLastModified = i18n.get("Unknown");
    long lastModifiedMS = 0L;
    Calendar lastModified = groupPage.getLastModified();
    if (lastModified != null) {
        xssLastModified = rtf.format(groupPage.getLastModified().getTimeInMillis(), true);
    }
    lastModifiedMS = lastModified.getTimeInMillis();

    String xssTitle = null;
    if (appInstance != null && appInstance.isA(MobileResourceType.INSTANCE.getType())) {
        String appName = appInstance.getProperties().get("widget/name/text", String.class);
        xssTitle = xssAPI.encodeForHTML(appName);
    }
    if (StringUtils.isBlank(xssTitle)) {
        xssTitle = xssAPI.encodeForHTML(pageResource.getTitle());
    }
    if (StringUtils.isBlank(xssTitle)) {
        xssTitle = xssAPI.encodeForHTML(pageResource.getName());
    }
    String xssThumbnailUrl = getThumbnailUrl(resource, xssAPI, request, log);
    String contextPath = request.getContextPath();
    String dashboardURL = getResourceUrl(resource, xssAPI, contextPath);

    AttrBuilder coralCardAttrs = new AttrBuilder(request, xssAPI);
    coralCardAttrs.add("colorhint", "#ffffff");
    coralCardAttrs.addClass("coral-Card");
    coralCardAttrs.addClass("cq-apps-app-card");
    coralCardAttrs.addClass("custom-app-card");
    coralCardAttrs.addClass("card-page");
    coralCardAttrs.addOther("timeline", "false");
    coralCardAttrs.addClass("foundation-collection-navigator");
    coralCardAttrs.addOther("foundation-collection-navigator-href", dashboardURL);

    final String configPath = appInstance.getProperties().get("widgetConfigPath", String.class);
    final Resource configRes = resourceResolver.getResource(configPath);
    final Document configDoc = loadConfigDocument(configRes);

    final long updateTime = appInstance.getProperties().get("updateTimestamp", 0L);

    AccessControlManager acm = null;
    try {
        acm = resourceResolver.adaptTo(Session.class).getAccessControlManager();
    } catch (RepositoryException e) {
        log.error("Unable to get access manager", e);
    }

    final String href = "/libs/mobileapps/admin/content/dashboard/appdetails.html" + Text.escape(appInstance.getPath());

%><coral-card <%=coralCardAttrs.build()%>>
    <coral-card-asset>
        <img src="<%= xssThumbnailUrl %>">
    </coral-card-asset><%
    if (updateTime > 0) {
    %><coral-card-info>
        <coral-alert variant="info">
            <coral-alert-header></coral-alert-header>
            <coral-alert-content>Content has been staged.</coral-alert-content>
        </coral-alert>
    </coral-card-info><%
    }
    %><coral-card-content class="coral-Card-content">
        <coral-card-title class="foundation-collection-item-title coral-Card-title"><%= xssTitle %></coral-card-title>
    </coral-card-content>
    <coral-card-propertylist>
        <coral-card-property icon="edit" title="<%= xssAPI.encodeForHTMLAttr(i18n.get("Modified")) %>">
            <time datetime="<%= lastModifiedMS %>"><%= xssLastModified %></time>
        </coral-card-property><%
        if (configDoc != null) {
            String targetIcon = "devices";
            String targetDevice = getPreference(configDoc, "target-device").getAttribute("value");
            if ("handset".equals(targetDevice)) {
                targetIcon = "devicePhone";
            } else if ("tablet".equals(targetDevice)) {
                targetIcon = "deviceTablet";
            }
        %><coral-card-property icon="<%= targetIcon %>"></coral-card-property><%
        }
        final String[] platforms = appInstance.getProperties().get("widget/platforms", String[].class);
        if (platforms != null && platforms.length > 0) {
            String platformIcon = "";
            for (String p : platforms) {
                if ("ios".equals(p)) {
                    platformIcon = "apple";
                } else if ("winphone".equals(p)) {
                    platformIcon = "windows";
                } else {
                    platformIcon = p;
                }
        %><coral-card-property icon="<%= platformIcon %>"></coral-card-property><%
            }
        }
    %></coral-card-propertylist>
    <link rel="properties" href="<%= dashboardURL %>"/>
    <meta class="foundation-collection-quickactions" data-foundation-collection-quickactions-rel="<%= xssAPI.encodeForHTMLAttr(StringUtils.join(getActionRels(resource, acm), " ")) %>">
</coral-card>
<coral-quickactions target="_prev" alignmy="left top" alignat="left top">
    <coral-quickactions-item icon="check" class="foundation-collection-item-activator"><%= xssAPI.encodeForHTML(i18n.get("Select")) %></coral-quickactions-item><%
    if (href != null) {
    %><coral-quickactions-item icon="infoCircle" type="anchor" href="<%= xssAPI.getValidHref(request.getContextPath() + href) %>"
><%= xssAPI.encodeForHTML(i18n.get("View Properties")) %></coral-quickactions-item><%
    }
%></coral-quickactions>
<%!
    private String getResourceUrl(Resource pageResource, XSSAPI xssAPI, String contextPath) {
        String pagePath = Text.escapePath(pageResource.getPath());
        return xssAPI.getValidHref(contextPath + "/libs/mobileapps/admin/content/dashboard.html" + pagePath);
    }

    private String getThumbnailUrl(Resource pageResource, XSSAPI xssAPI, HttpServletRequest request, Logger log) {
        String ck = getCacheKiller(pageResource, log);
        if (ck == null || ck.isEmpty()) {
            try {
                ValueMap metadata = pageResource.getChild(JcrConstants.JCR_CONTENT + "/image").adaptTo(ValueMap.class);
                String fileReference = metadata.get("fileReference", String.class);
                if (fileReference != null) {
                    Resource fileRefRes = pageResource.getResourceResolver().resolve(fileReference);
                    if (fileRefRes != null) {
                        ck = getCacheKiller(fileRefRes, log);
                    }
                }
            } catch(Exception ex) {
                log.error("Unable to get thumbnail url", ex);
            }
        }

        return xssAPI.getValidHref(request.getContextPath() + Text.escapePath(pageResource.getPath()) + ".thumb.319.319.png?ck=" + ck);
    }

    private String getCacheKiller(Resource resource, Logger log) {
        Calendar calendar = Calendar.getInstance();
        String ck = "" + (calendar.getTimeInMillis() / 1000);

        try {

            ValueMap metadata = null;
            if (resource != null && resource.isResourceType("cq:Page")) {
                metadata = resource.getChild("image/file/jcr:content").adaptTo(ValueMap.class);
            } else if (resource.isResourceType("dam:Asset")) {
                metadata = resource.getChild("jcr:content").adaptTo(ValueMap.class);
            }

            if (metadata != null) {
                calendar = metadata.get("jcr:lastModified", Calendar.class);
                if (calendar != null) {
                    ck = "" + (calendar.getTimeInMillis() / 1000);
                }
            }
        } catch (Exception ex) {
            log.error("Unable to create cache killer", ex);
        }

        return ck;
    }

    private List<String> getActionRels(Resource resource, AccessControlManager acm) {
        List<String> actionRels = new ArrayList<String>();

        if (hasPermission(acm, resource, Privilege.JCR_REMOVE_NODE)) {
            actionRels.add("cq-apps-admin-actions-delete-app-activator");
        }

        Resource content = resource.getChild(JcrConstants.JCR_CONTENT);
        ValueMap properties = content.getValueMap();
        if (properties.containsKey("phonegapConfig")) {
            actionRels.add("cq-apps-admin-actions-pgbuildremote-activator");
            actionRels.add("cq-apps-admin-actions-downloadcli-activator");
        }

        // Add an unassigned activator or else the user could get ALL actions if none are set for them.
        if (actionRels.isEmpty()) {
            actionRels.add("cq-apps-no-activators");
        }

        return actionRels;
    }

    private boolean hasPermission(AccessControlManager acm, Resource resource, String privilege) {
        if (acm != null) {
            try {
                Privilege p = acm.privilegeFromName(privilege);
                return acm.hasPrivileges(resource.getPath(), new Privilege[] { p });
            } catch (RepositoryException ignore) {
            }
        }
        return false;
    }

    public Document loadConfigDocument(Resource resource) {
        if (resource != null) {
            try {
                // if the resource path is in DAM, need to fetch the original and not the rendition
                Asset configAsset = resource.adaptTo(Asset.class);
                if (configAsset != null) {
                    resource = configAsset.getOriginal();
                }

                DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
                dbf.setNamespaceAware(true);
                dbf.setIgnoringComments(true);
                dbf.setExpandEntityReferences(true);

                InputStream configIS = resource.adaptTo(InputStream.class);
                DocumentBuilder db = dbf.newDocumentBuilder();
                return db.parse(configIS);
            } catch (Exception e) {
                return null;
            }
        }

        return null;
    }

    public Element getPreference(Document doc, String name) {
        NodeList nList = doc.getElementsByTagName("preference");
        for (int i = 0; i < nList.getLength(); i++) {
            org.w3c.dom.Node prefNode = nList.item(i);
            if (prefNode.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                Element eElement = (Element) prefNode;
                if (eElement.getAttribute("name").equals(name)) {
                    return eElement;
                }
            }
        }
        return null;
    }
%>
