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
		m_runDatabaseScripts.execute();
	}

}
