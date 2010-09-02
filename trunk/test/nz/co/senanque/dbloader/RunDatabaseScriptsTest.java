package nz.co.senanque.dbloader;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration
public class RunDatabaseScriptsTest{
    
    @Autowired private RunDatabaseScripts m_runDatabaseScripts;

    @Test
	public void testExecute() throws Exception
	{
//		RunDatabaseScripts r = new RunDatabaseScripts();
//		r.setDir("/home/roger/telstraPOC/aldous_plm_app/build/tmp/db_scripts/custom/CleanBuild");
//		r.setDriver("oracle.jdbc.driver.OracleDriver");
//		r.setDrop(true);
//		r.setJdbcURL("jdbc:oracle:thin:@localhost:1521:XE");
//		r.setSystemPassword("wefixit4U");
		m_runDatabaseScripts.execute();
	}

}
