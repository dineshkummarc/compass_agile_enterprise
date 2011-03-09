namespace :axiom do

  desc 'Starts Axiom '
  task(:start => :environment) do
    os_path_separator= Constants::OS_PATH_SEPARATOR # for windows use ';' for *nix use ':'
 
    axiom_lib_path="#{File.dirname(__FILE__)}../../../jlib"
    ENV['CLASSPATH'] = axiom_lib_path+"/axiom_server.jar"+
      os_path_separator+axiom_lib_path+"/commons-lang-2.4.jar"+
      os_path_separator+axiom_lib_path+"/antlr-runtime.jar"+
      os_path_separator+axiom_lib_path+"/datedFileAppender-1.0.2.jar"+
      os_path_separator+axiom_lib_path+"/drools-compiler.jar"+
      os_path_separator+axiom_lib_path+"/drools-core.jar"+
      os_path_separator+axiom_lib_path+"/drools-decisiontables.jar"+
      os_path_separator+axiom_lib_path+"/drools-jsr94.jar"+
      os_path_separator+axiom_lib_path+"/jsr94.jar"+
      os_path_separator+axiom_lib_path+"/junit.jar"+
      os_path_separator+axiom_lib_path+"/jxl.jar"+
      os_path_separator+axiom_lib_path+"/log4j-1.2.15.jar"+
      os_path_separator+axiom_lib_path+"/mvel.jar"+
      os_path_separator+axiom_lib_path+"/org.drools.eclipse_4.0.7.jar"+
      os_path_separator+axiom_lib_path+"/org.eclipse.jdt.core_3.4.4.v_894_R34x.jar"+
      os_path_separator+axiom_lib_path+"/xercesImpl.jar"+
      os_path_separator+axiom_lib_path+"/xml-apis.jar"+
      os_path_separator+axiom_lib_path+"/xpp3.jar"+
      os_path_separator+axiom_lib_path+"/xpp3_min.jar"+
      os_path_separator+axiom_lib_path+"/xstream.jar"+
      os_path_separator+axiom_lib_path+"/compassERP_models.jar"+
      os_path_separator+axiom_lib_path+"/jchronic-0.2.3.jar"

    exec "java -Dalt.dir=vendor/plugins/erp_rules/vendor/plugins/axiom  com.tnsolutionsinc.axiom.Main"

  end

end
