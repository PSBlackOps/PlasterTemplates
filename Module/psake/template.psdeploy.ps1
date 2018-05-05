# Deploy to the .\Build folder
Deploy 'Copy module to build folder' {
    By Filesystem {
<%
"        FromSource '.\$PLASTER_PARAM_ModuleName\'"
"        To '$PLASTER_PARAM_ModuleName\Build'"
%>
    }
}
