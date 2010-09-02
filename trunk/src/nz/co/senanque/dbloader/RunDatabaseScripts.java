/**
 * 
 */
package nz.co.senanque.dbloader;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.MessageFormat;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.lang.time.DurationFormatUtils;
import org.apache.tools.ant.Task;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author roger
 *
 */
public class RunDatabaseScripts extends Task {
	
	private static final Logger logger = LoggerFactory.getLogger(RunDatabaseScriptsTest.class);
	
	String m_dir;
	String m_driver;
	String m_jdbcURL;
	boolean m_drop;
	boolean m_debug;

	String m_systemPassword;
	String m_systemUser = "SYSTEM";
	public String getSystemUser() {
		return m_systemUser;
	}
	public void setSystemUser(String systemUser) {
		m_systemUser = systemUser;
	}

	String m_defaultTableSpace = "USERS";
	String m_currentFile = "";
	String m_delimiter = "-";
	
	public String getDelimiter() {
		return m_delimiter;
	}
	public void setDelimiter(String delimiter) {
		m_delimiter = delimiter;
	}

	String[] m_ignoreCommands = new String[]{"PROMPT","EXIT","--","SET","REM","COMMIT"};

	private int m_lineCount=0;
	private int m_errorCount=0;
	
	
	public boolean isDebug() {
		return m_debug;
	}
	public void setDebug(boolean debug) {
		m_debug = debug;
	}
    public String getDefaultTableSpace() {
		return m_defaultTableSpace;
	}


	public void setDefaultTableSpace(String defaultTableSpace) {
		m_defaultTableSpace = defaultTableSpace;
	}


	public String getDir() {
		return m_dir;
	}


	public void setDir(String dir) {
		m_dir = dir;
	}


	public String getDriver() {
		return m_driver;
	}


	public void setDriver(String driver) {
		m_driver = driver;
	}


	public String getJdbcURL() {
		return m_jdbcURL;
	}


	public void setJdbcURL(String jdbcURL) {
		m_jdbcURL = jdbcURL;
	}


	public boolean isDrop() {
		return m_drop;
	}


	public void setDrop(boolean drop) {
		m_drop = drop;
	}


	public String getSystemPassword() {
		return m_systemPassword;
	}


	public void setSystemPassword(String systemPassword) {
		m_systemPassword = systemPassword;
	}


	public void execute() {
		
		long start = System.currentTimeMillis();
		
		registerDriver();
    	
    	File dir = new File(getDir());
    	if (!dir.isDirectory())
    	{
    		throw new RuntimeException(getDir()+" is not a directory");
    	}
    	File[] files = dir.listFiles(new FilenameFilter(){

			public boolean accept(File arg0, String arg1) {
				if (arg1.toUpperCase().endsWith("SQL"))
				{
					return true;
				}
				return false;
			}});

    	Set<String> sqlFiles = new TreeSet<String>();
    	Set<String> users = new TreeSet<String>();
    	for (File f: files)
    	{
    		String name = f.getName();
    		sqlFiles.add(name);
    		users.add(extractUserName(name));
    	}
    	if (m_drop)
    	{
    		dropUsers(users);
    	}
    	for (String f: sqlFiles)
    	{
    		m_currentFile = f;
    		processFile(getDir()+"/"+f,f);
    	}
    	logger.info(MessageFormat.format("{0,number,integer} files processed in {1}",
    			files.length,DurationFormatUtils.formatDuration(System.currentTimeMillis()-start,"HH:mm:ss.SS")));
    	if (m_errorCount>0)
    	{
    		throw new RuntimeException(MessageFormat.format("Error count: {0,number,integer}. See log for details",m_errorCount));
    	}
    }
	
	private void registerDriver()
	{
		 try {
			Driver driver = (Driver)Class.forName(getDriver()).newInstance();
			 DriverManager.registerDriver(driver);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}

	private String extractUserName(String name)
	{
		String delimiter = getDelimiter();
		int i = name.indexOf(delimiter);
		if (i == -1)
		{
			throw new RuntimeException(MessageFormat.format("{0} missing first {1}",name,delimiter));
		}
		int i1 = name.indexOf(delimiter,i+1);
		if (i1 == -1)
		{
			throw new RuntimeException(MessageFormat.format("{0} missing second {1}",name,delimiter));
		}
		String ret = name.substring(i+1,i1);
		return ret;
	}

	private void processFile(String f, String shortF) 
	{
		String user = extractUserName(f);
		String password = user.toLowerCase();
		if (user.equals(getSystemUser()))
		{
			password = getSystemPassword();
		}
		logger.info(MessageFormat.format("processing file: {0}",f));
		Connection connection = getJDBCConnection(user,password);
		try {
		    connection.setAutoCommit(false);
			processScript(connection, new FileReader(f),false,shortF);
			connection.commit();
			connection.close();
		} catch (Exception e) {
			logger.error(e.getMessage(),e);
		}
	}

	private void processScript(Connection connection, Reader reader, boolean keepGoingOnError,String fileName) {
	    
		Statement statement=null;
		try {
			statement = connection.createStatement();
		} catch (SQLException e1) {
			throw new RuntimeException(e1);
		}
		m_lineCount = 0;
		BufferedReader br = new BufferedReader(reader);
		String s = getNextStatement(br);
		while (s != null)
		{
			try {
				String s1 = s.trim().toUpperCase();
				logger.debug(s);
				if ((m_lineCount % 1000) == 0)
				{
					logger.info(MessageFormat.format("processing line: {0,number,integer} of {1}",m_lineCount,m_currentFile));
				}
				boolean ignoreCommand = false;
				for (String ignore: m_ignoreCommands)
				{
					if (s1.startsWith(ignore))
					{
						ignoreCommand = true;
						break;
					}
				}
				if (!ignoreCommand)
				{
					boolean b = statement.execute(s);
					if (b)
					{
						// We have a resultSet
						ResultSet rs = statement.getResultSet();
						ResultSetMetaData rsmd = rs.getMetaData();
						int columnCount = rsmd.getColumnCount();
						{
							StringBuilder sb = new StringBuilder();
							for (int i=1;i<=columnCount;i++)
							{
								sb.append(rsmd.getColumnName(i));
								sb.append(",");
							}
							debug(sb);
						}
						while (rs.next())
						{
							StringBuilder sb = new StringBuilder();
							for (int i=1;i<=columnCount;i++)
							{
								sb.append(rs.getString(i));
								sb.append(",");
							}
							debug(sb);
						}
						rs.close();
					}
				}
			} catch (SQLException e) {
				String s1 = e.getMessage();
				String s2 = MessageFormat.format("error at line: {0,number,integer} of {1}: {2}\n{3}",new Object[]{m_lineCount,fileName,s1,s});
				if (!s1.startsWith("ORA-00955"))
				{
					if (!keepGoingOnError)
					{
	                    logger.error(s2);
	                    m_errorCount++;
						break;
					}
				}
                logger.warn(s2);
			}
			s = getNextStatement(br);
		}
		try {
			statement.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	private void debug(Object message)
	{
		if (m_debug)
		{
			logger.info("[debug] "+message.toString());
		}
	}

	private String getNextStatement(BufferedReader br)
	{
		StringBuilder ret = new StringBuilder();
		try {
			String line = getNextLine(br);
			while (line != null)
			{
				line = line.trim();
				String s = line.toUpperCase();
				ret.append(line);
				ret.append(" ");
				if (s.startsWith("CREATE OR REPLACE FUNCTION"))
				{
					huntForEnd(br,ret);
				}
				if (s.startsWith("CREATE OR REPLACE PROCEDURE"))
				{
					huntForEnd(br,ret);
				}
				if (s.startsWith("CREATE OR REPLACE TRIGGER"))
				{
					huntForEnd(br,ret);
				}
				if (ret.toString().endsWith("; "))
				{
					break;
				}
				line = getNextLine(br);
			}
			if (ret.length()==0)
			{
				return null;
			}
			return ret.substring(0, ret.length()-2).toString();
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private void huntForEnd(BufferedReader br, StringBuilder ret) {
		try {
			String line = getNextLine(br);
			while (line != null)
			{
				line = line.trim();
				if (!line.startsWith("--"))
				{
					if (line.equals("/"))
					{
						ret.append("; ");
						break;
					}
					ret.append(line);
					ret.append(" ");
				}
				line = getNextLine(br);
			}
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
	}

	private String getNextLine(BufferedReader br) throws IOException
	{
		String line = br.readLine();
		m_lineCount++;
		while (line != null)
		{
			String s = line.trim().toUpperCase();
			if (!s.startsWith("--") && !s.startsWith("REM") && !s.startsWith("#") && !s.startsWith("//"))
			{
				return line;
			}
			line = br.readLine();
			m_lineCount++;
		}
		return null;
	}

	private void dropUsers(Set<String> users) {
		Connection connection = getJDBCConnection("SYSTEM",getSystemPassword());
		logger.info(MessageFormat.format("dropping users: {0}",users.toString()));
		StringBuilder sb = new StringBuilder();
		for (String user: users)
		{
			if (user.equals(getSystemUser()))
			{
				continue;
			}
//	         echo "drop user $CurUser cascade;" > tmprecreateorauser.sql
			sb.append("drop user "+user+" cascade;\n");
		}
		processScript(connection, new StringReader(sb.toString()),true, "internal-drop users");
		logger.info("dropped users");
		
		logger.info(MessageFormat.format("recreating users: {0}",users.toString()));
		sb = new StringBuilder();
		for (String user: users)
		{
			if (user.equals(getSystemUser()))
			{
				continue;
			}
//	         echo "CREATE USER \"$CurUser\" PROFILE \"DEFAULT\" " >> tmprecreateorauser.sql
//	         echo "IDENTIFIED BY \"$CurPassword\" DEFAULT TABLESPACE \"$DEFAULTTABLESPACE\" " >> tmprecreateorauser.sql
//	         echo "ACCOUNT UNLOCK;" >> tmprecreateorauser.sql
//	         echo "GRANT \"CONNECT\", \"RESOURCE\" TO \"$CurUser\"; " >> tmprecreateorauser.sql
//	         echo "GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER, CREATE SEQUENCE TO \"$CurUser\";" >> tmprecreateorauser.sql
//	         echo "quit" >> tmprecreateorauser.sql
			sb.append("create user "+user+" profile \"DEFAULT\" \n");
			sb.append(" identified by "+user.toLowerCase()+" default tablespace \""+getDefaultTableSpace()+"\" \n");
			sb.append(" account unlock;\n");
			sb.append("grant \"CONNECT\",\"RESOURCE\" to "+user+";\n");
			sb.append("grant CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE TRIGGER, CREATE SEQUENCE to "+user+";\n");
		}
		processScript(connection, new StringReader(sb.toString()), false, "internal-create users");

		try {
			connection.close();
		} catch (SQLException e) {
			logger.debug(MessageFormat.format("error on connection close: {0}",e.getMessage()));
		}
		logger.info("dropping/recreating users complete");
	}

	private Connection getJDBCConnection(String user, String password) {
		try {
			debug(MessageFormat.format("connecting to {0} {1}", getJdbcURL(),user));
			return DriverManager.getConnection(getJdbcURL(), user, password);
		} catch (SQLException e) {
			throw new RuntimeException(e);
		}
	}
}
