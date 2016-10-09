# Fix DNS
rm /etc/resolv.conf
ln -s ../run/resolvconf/resolv.conf /etc/resolv.conf
resolvconf -u

# Update cache
apt-get update
# Upgrade packages
apt-get upgrade -y

# Install dependencies
apt-get install unzip -y

# Install Oracle Java 6
add-apt-repository ppa:webupd8team/java
apt-get update
# Disable prompting
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
apt-get install oracle-java6-installer -y

# Install PostgreSQL
apt-get install postgresql -y

# Download, unzip and move the folder to /opt
wget http://downloads.sourceforge.net/project/pentaho/Business%20Intelligence%20Server/5.1/biserver-ce-5.1.0.0-752.zip
mkdir -p /opt/pentaho
unzip biserver-ce-5.1.0.0-752.zip -d /opt/pentaho

# Change a detail in pg_hba.conf
sed -i s/"local   all             all                                     peer"/"local   all             all                                     trust"/g /etc/postgresql/9.5/main/pg_hba.conf

# Add future needed user
useradd pentaho_user

# Reload service
systemctl restart postgresql

# Create support databases
sudo -u postgres psql -a -f /opt/pentaho/biserver-ce/data/postgresql/create_jcr_postgresql.sql
sudo -u postgres psql -a -f /opt/pentaho/biserver-ce/data/postgresql/create_repository_postgresql.sql
sudo -u postgres psql -a -f /opt/pentaho/biserver-ce/data/postgresql/create_quartz_postgresql.sql
sudo -u postgres psql -a quartz -c 'CREATE TABLE "QRTZ"(NAME VARCHAR(200) NOT NULL,PRIMARY KEY (NAME));'

# Download PostgreSQL JDBC driver
cd /usr/share/java
wget jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc4.jar

# Symlink for naming
ln -s postgresql-9.3-1102.jdbc4.jar postgresql-9.3-jdbc4.jar

# Symlink for the Pentaho's Tomcat folder
cd /opt/pentaho/biserver-ce/tomcat/lib
ln -s /usr/share/java/postgresql-9.3-jdbc4.jar postgresql-9.3-jdbc4.jar

# Pentaho context.xml configuration
sed -i s/"org.hsqldb.jdbcDriver"/"org.postgresql.Driver"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml
sed -i s/"jdbc:hsqldb:hsql:\/\/localhost\/hibernate"/"jdbc:postgresql:\/\/localhost:5432\/hibernate"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml
sed -i s/"select count(\*) from INFORMATION_SCHEMA.SYSTEM_SEQUENCES"/"select 1"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml
sed -i s/"org.hsqldb.jdbcDriver"/"org.postgresql.Driver"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml
sed -i s/"jdbc:hsqldb:hsql:\/\/localhost\/quartz"/"jdbc:postgresql:\/\/localhost:5432\/quartz"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml
sed -i s/"select count(\*) from INFORMATION_SCHEMA.SYSTEM_SEQUENCES"/"select 1"/g /opt/pentaho/biserver-ce/tomcat/webapps/pentaho/META-INF/context.xml

# Pentaho's applicationContext-spring-security-hibernate.properties
sed -i s/"org.hsqldb.jdbcDriver"/"org.postgresql.Driver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties
sed -i s/"jdbc:hsqldb:hsql:\/\/localhost\/hibernate"/"jdbc:postgresql:\/\/localhost:5432\/hibernate"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties

# Pentaho's hibernate-settings.xml
sed -i s/"system\/hibernate\/hsql.hibernate.cfg.xml"/"system\/hibernate\/postgresql.hibernate.cfg.xml"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/hibernate/hibernate-settings.xml

# Pentaho's jdbc.properties
sed -i s/"SampleData\/type=javax.sql.DataSource"/"#SampleData\/type=javax.sql.DataSource"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleData\/driver=org.hsqldb.jdbcDriver"/"#SampleData\/driver=org.hsqldb.jdbcDriver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleData\/url=jdbc:hsqldb:hsql:\/\/localhost\/sampledata"/"#SampleData\/url=jdbc:hsqldb:hsql:\/\/localhost\/sampledata"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleData\/user=pentaho_user"/"#SampleData\/user=pentaho_user"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleData\/password=password"/"#SampleData\/password=password"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Hibernate\/driver=org.hsqldb.jdbcDriver"/"Hibernate\/driver=org.postgresql.Driver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Hibernate\/url=jdbc:hsqldb:hsql:\/\/localhost\/hibernate"/"Hibernate\/url=jdbc:postgresql:\/\/localhost:5432\/hibernate"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Quartz\/driver=org.hsqldb.jdbcDriver"/"Quartz\/driver=org.postgresql.Driver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Quartz\/url=jdbc:hsqldb:hsql:\/\/localhost\/quartz"/"Quartz\/url=jdbc:postgresql:\/\/localhost:5432\/quartz"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Shark\/type=javax.sql.DataSource"/"#Shark\/type=javax.sql.DataSource"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Shark\/driver=org.hsqldb.jdbcDriver"/"#Shark\/driver=org.hsqldb.jdbcDriver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Shark\/url=jdbc:hsqldb:hsql:\/\/localhost\/shark"/"#Shark\/url=jdbc:hsqldb:hsql:\/\/localhost\/shark"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Shark\/user=sa"/"#Shark\/user=sa"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"Shark\/password="/"#Shark\/password="/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleDataAdmin\/type=javax.sql.DataSource"/"#SampleDataAdmin\/type=javax.sql.DataSource"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleDataAdmin\/driver=org.hsqldb.jdbcDriver"/"#SampleDataAdmin\/driver=org.hsqldb.jdbcDriver"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleDataAdmin\/url=jdbc:hsqldb:hsql:\/\/localhost\/sampledata"/"#SampleDataAdmin\/url=jdbc:hsqldb:hsql:\/\/localhost\/sampledata"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleDataAdmin\/user=pentaho_admin"/"#SampleDataAdmin\/user=pentaho_admin"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties
sed -i s/"SampleDataAdmin\/password=password"/"#SampleDataAdmin\/password=password"/g /opt/pentaho/biserver-ce/pentaho-solutions/system/simple-jndi/jdbc.properties

# Permission check
chmod +x /opt/pentaho/biserver-ce/*.sh

# Install the service into systemd
cp /vagrant/pentaho-bi.service /etc/systemd/system/
# Enable automatic startup
systemctl enable pentaho-bi.service
# Start pentaho
systemctl start pentaho-bi.service
