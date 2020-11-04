<?xml version="1.0" encoding="UTF-8"?>
<Configuration>
  <Properties>
    <Property name="logfile.path">/home/ec2-user</Property>
  </Properties>
  <Appenders>
    <Console name="STDOUT" target="SYSTEM_OUT">
      <PatternLayout pattern="%d %p %c{2} :: %m%n">
        <replace regex=":basic-auth \\[.*\\]" replacement=":basic-auth [redacted]"/>
      </PatternLayout>
    </Console>


    <RollingFile name="FILE" fileName="${logfile.path}/metabase.log" filePattern="${logfile.path}/metabase.log.%i">
      <Policies>
        <SizeBasedTriggeringPolicy size="200 MB"/>
      </Policies>
      <DefaultRolloverStrategy max="10"/>
      <PatternLayout pattern="%d [%t] %-5p%c - %m%n">
        <replace regex=":basic-auth \\[.*\\]" replacement=":basic-auth [redacted]"/>
      </PatternLayout>
    </RollingFile>
  </Appenders>

  <Loggers>
    <Logger name="metabase" level="INFO"/>
    <Logger name="metabase.plugins" level="DEBUG"/>
    <Logger name="metabase.middleware" level="DEBUG"/>
    <Logger name="metabase.query-processor.async" level="DEBUG"/>
    <Logger name="com.mchange" level="ERROR"/>

    <Root level="WARN">
      <AppenderRef ref="FILE"/>
    </Root>
  </Loggers>
</Configuration>
