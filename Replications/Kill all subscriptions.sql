-- **** ����� 1 *****
use [master]
exec sp_dropdistributor @no_checks = 1
GO


-- **** ����� 2 *****

EXEC sp_replicationdboption @dbname = '<dbname>, @optname = 'publish', @value = 'FALSE' 


-- **** ����� 3 *****
DECLARE @subscriptionDB AS sysname
SET @subscriptionDB = N'<dbname>

-- Remove replication objects from a subscription database (if necessary).
USE master
EXEC sp_removedbreplication @subscriptionDB
GO
