package com.tnsolutionsinc.axiom.server;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.rmi.RemoteException;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

import org.apache.log4j.Logger;
import org.drools.RuleBase;
import org.drools.RuleBaseFactory;
import org.drools.WorkingMemory;
import org.drools.compiler.PackageBuilder;
import org.drools.event.ActivationCancelledEvent;
import org.drools.event.ActivationCreatedEvent;
import org.drools.event.AfterActivationFiredEvent;
import org.drools.event.AfterFunctionRemovedEvent;
import org.drools.event.AfterPackageAddedEvent;
import org.drools.event.AfterPackageRemovedEvent;
import org.drools.event.AfterRuleAddedEvent;
import org.drools.event.AfterRuleBaseLockedEvent;
import org.drools.event.AfterRuleBaseUnlockedEvent;
import org.drools.event.AfterRuleRemovedEvent;
import org.drools.event.AgendaEventListener;
import org.drools.event.AgendaGroupPoppedEvent;
import org.drools.event.AgendaGroupPushedEvent;
import org.drools.event.BeforeActivationFiredEvent;
import org.drools.event.BeforeFunctionRemovedEvent;
import org.drools.event.BeforePackageAddedEvent;
import org.drools.event.BeforePackageRemovedEvent;
import org.drools.event.BeforeRuleAddedEvent;
import org.drools.event.BeforeRuleBaseLockedEvent;
import org.drools.event.BeforeRuleBaseUnlockedEvent;
import org.drools.event.BeforeRuleRemovedEvent;
import org.drools.event.ObjectInsertedEvent;
import org.drools.event.ObjectRetractedEvent;
import org.drools.event.ObjectUpdatedEvent;
import org.drools.event.RuleBaseEventListener;
import org.drools.event.WorkingMemoryEventListener;
import org.drools.rule.Package;
import org.drools.rule.Rule;

import com.tnsolutionsinc.axiom.Utils;
import com.tnsolutionsinc.axiom.context.CustomerContext;
import com.tnsolutionsinc.axiom.context.EnvironmentContext;
import com.tnsolutionsinc.axiom.context.ExecutionContext;
import com.tnsolutionsinc.axiom.context.SearchContext;
import com.tnsolutionsinc.compass.model.ResultMap;

public class RuleExecutorImpl implements RuleExecutor {
	public static Logger logger = Logger
			.getLogger("com.tnsolutionsinc.axiom.server.RuleExecutorImpl");
	private Properties config = null;

	public RuleExecutorImpl(Properties config) {
		this.config = config;
	}

	public HashMap invoke(List ruleset, ExecutionContext executionContext)
			throws RemoteException {
		logger.debug("Ruleset:" + ruleset);
		logger.debug("execution context:" + executionContext);
		ResultMap resultMap = new ResultMap();
		// comment out execution context for during dev
		
		resultMap.put("EXECUTION_CONTEXT", executionContext); 
		
		// to the result map
	 // execute rules here
		try {

			// load up the rulebase
			RuleBase ruleBase = loadRules(ruleset);
			WorkingMemory workingMemory = ruleBase.newStatefulSession();
			// add the listener to automatically add the fired event to the resultMap
			AxiomAgendaEventListener listener = new AxiomAgendaEventListener(resultMap);
			workingMemory.addEventListener(listener);
			// load the execution context 
			Collection values=executionContext.values();
			Iterator i=values.iterator();
			
			
			while(i.hasNext()){
				Object ctx_element=i.next();
				logger.info("Adding ["+ctx_element+"] to RuleBase");
				workingMemory.insert(ctx_element);
				logger.debug("WORKING MEMORY ctx_element INSERT:"+ctx_element);
			}
			 
			//add the result map to the working memory
			workingMemory.insert(resultMap);
			
			// go !
			workingMemory.fireAllRules();
			
			

		} catch (Throwable t) {
			t.printStackTrace();
			resultMap.put("status", "exception");
			resultMap.put("exception",t.getMessage());
		}

		//
		
		return resultMap;
	}

	private Reader getRuleSourceReader(String ruleName) throws Exception {
		// read in the source
		File rulePath=Utils.getAltFile(config.getProperty("rule.path"));
		File ruleFile = new File( rulePath, ruleName+ ".drl");
		logger.info("loading Rule:"+ruleFile.getAbsolutePath());
		return new InputStreamReader(new FileInputStream(ruleFile));
	}

	private RuleBase loadRules(List ruleset) throws Exception {

		// Use package builder to build up a rule package.

		PackageBuilder builder = new PackageBuilder();

		for (Iterator i = ruleset.iterator(); i.hasNext();) {
			Reader source = getRuleSourceReader(i.next().toString());
			builder.addPackageFromDrl(source);
		}

		// Use the following instead of above if you are using a DSL:
		// builder.addPackageFromDrl( source, dsl );

		// get the compiled package (which is serializable)
		Package pkg = builder.getPackage();

		// add the package to a rulebase (deploy the rule package).
		RuleBase ruleBase = RuleBaseFactory.newRuleBase();
		ruleBase.addPackage(pkg);
		Package[] packages=ruleBase.getPackages();
		for(int j=0;j<packages.length;j++){
			logger.debug("loaded package:"+packages[j]);
		}
		return ruleBase;
	}

	class AxiomAgendaEventListener implements AgendaEventListener{
		ResultMap resultMap = null;
		public AxiomAgendaEventListener(ResultMap map){
			this.resultMap=map;
		}
		@Override
		public void activationCancelled(ActivationCancelledEvent evt,
				WorkingMemory wm) {
			logger.info("activationCancelled "+evt+", working memory:"+wm);
			
		}

		@Override
		public void activationCreated(ActivationCreatedEvent evt,
				WorkingMemory wm) {
			logger.info("activationCreated "+evt+", working memory:"+wm);
			
		}

		@Override
		public void afterActivationFired(AfterActivationFiredEvent evt,
				WorkingMemory wm) {
			logger.info("afterActivationFired "+evt+", working memory:"+wm);
			Rule ruleFired= evt.getActivation().getRule();
			String ruleName=ruleFired.getName();
			logger.info("Rule Fired:"+ruleName);
			// here we add the rule fired to the resultMap
			resultMap.addRuleFired(ruleName);
			
		}

		@Override
		public void agendaGroupPopped(AgendaGroupPoppedEvent evt,
				WorkingMemory wm) {
			logger.info("agendaGroupPopped "+evt+", working memory:"+wm);
			
		}

		@Override
		public void agendaGroupPushed(AgendaGroupPushedEvent evt,
				WorkingMemory wm) {
			logger.info("agendaGroupPushed "+evt+", working memory:"+wm);
			
		}

		@Override
		public void beforeActivationFired(BeforeActivationFiredEvent evt,
				WorkingMemory wm) {
			logger.info("beforeActivationFired "+evt+", working memory:"+wm);
			
		}

		 

		  
  
		
	}
}
