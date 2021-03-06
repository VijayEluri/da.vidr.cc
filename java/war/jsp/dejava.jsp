<jsp:include page="header.jsp">
    <jsp:param name="title" value="DejaVa" />
</jsp:include>

<%@ page
    language="java"
    contentType="text/html;charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.io.*"
    import="java.util.*"
    import="cc.vidr.*"
    import="cc.vidr.dejava.*"
    import="org.apache.commons.lang.*"
    import="org.apache.commons.jci.problems.*"
%>

<p><a href="http://da.vidr.cc/projects/dejava/">DejaVa</a> compiles Java source code to JVM bytecode, then disassembles it to Jasmin assembly code.</p>
<p>Powered by:</p>
<ul>
<li><a href="http://commons.apache.org/jci/">JCI</a></li>
<li><a href="http://www.eclipse.org/jdt/core/">ECJ</a> (<a href="http://download.eclipse.org/eclipse/downloads/drops/R-3.5.1-200909170800/#JDTCORE">download</a>)</li>
<li><a href="http://code.google.com/p/classfileanalyzer/">ClassFileAnalyzer</a></li>
</ul>

<%
String classname = "HelloWorld";
String source =
    "public class HelloWorld {\n" +
    "    private class Foo {\n" +
    "        public void bar() {\n" +
    "            System.out.println(\"Hello world!\");\n" +
    "        }\n" +
    "    }\n" +
    "    public static void main(String[] args) {\n" +
    "        HelloWorld helloWorld = new HelloWorld();\n" +
    "        Foo foo = helloWorld.new Foo();\n" +
    "        foo.bar();\n" +
    "    }\n" +
    "}";
if(request.getMethod().equals("POST")) {
    classname = request.getParameter("classname");
    source = request.getParameter("source");
    String[] sourceLines = source.split("\r?\n");
%>

<h2>Compiling...</h2>
<%
    JavaSourceCompiler compiler =
        new JavaSourceCompiler(classname + ".java", source);
    compiler.compile();
    List<CompilationProblem> errors = compiler.getErrors();
    List<CompilationProblem> warnings = compiler.getWarnings();
%>

<%
    if(errors.size() != 0) {
%>
<div class="error">
<p><strong><%=errors.size()%> errors</strong></p>
<ul>
<%
    for(CompilationProblem error : errors) {
        out.print("<li>");
        StringEscapeUtils.escapeHtml(out, error.toString());
        out.println("</li>");
    }
%>
</ul>
</div>
<%
    }
%>

<%
    if(warnings.size() != 0) {
%>
<div class="notice">
<p><strong><%=warnings.size()%> warnings</strong></p>
<ul>
<%
        for(CompilationProblem warning : warnings) {
            out.print("<li>");
            StringEscapeUtils.escapeHtml(out, warning.toString());
            out.println("</li>");
        }
%>
</ul>
</div>
<%
    }
%>

<%
    if(compiler.successful()) {
%>
<div class="success">
    <p>Successfully compiled <%=classname%>.java</p>
</div>
<%
        for(String className : compiler.getClassNames()) {
%>
<h3><%=className%></h3>
<pre>
<%
            JavaClassDecompiler decompiler = new JavaClassDecompiler(
                    className, compiler.getClassData(className));
            try {
                decompiler.decompile();
                String assemblyCode[] =
                    decompiler.getAssemblyCode().split("\r?\n");
                for(String line : assemblyCode) {
                    if(line.startsWith("  .line")) {
                        int lineNum = Integer.decode(
                                line.substring("  .line ".length()));
                        out.print(";<strong>");
                        StringEscapeUtils.escapeHtml(out,
                                sourceLines[lineNum-1]);
                        out.println("</strong>");
                    }
                    if(line.startsWith(".") || line.startsWith("  .")) {
                        out.print("<em>");
                        StringEscapeUtils.escapeHtml(out, line);
                        out.println("</em>");
                    } else {
                        StringEscapeUtils.escapeHtml(out, line);
                        out.println();
                    }
                }
            } catch (ClassFormatError e) {
                StringEscapeUtils.escapeHtml(out,
                        "; Error decompiling class file:\n" +
                        "; " + e.toString().replace("\n", "\n; "));
            }
%>
</pre>
<%
        }
    }
}
%>

<form action="" method="post">
<fieldset>
    <legend>Java Source File</legend>
    <p>
        <label for="classname">Filename</label><br />
        <input type="text" class="title" name="classname" id="classname" value="<%=classname%>" /><strong>.java</strong>
    </p>
    <p>
        <label for="source">Source</label><br />
        <textarea rows="20" cols="80" name="source" id="source"><%StringEscapeUtils.escapeHtml(out, source);%></textarea>
    </p>
    <p>
        <input type="submit" value="Submit" />
        <input type="reset" value="Reset" />
    </p>
</fieldset>
</form>

<jsp:include page="footer.jsp" />
