########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                    MCSOC install script
#                  Create DB for cron profile
#
#
# PLEASE DO NOT EDIT
#
#                                               VERSION: 1.0
########################################################################


# For Full Backup
# [ MON - SUN / 6am - 7am ] Once a week / Every 10 minutes
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 \
    'create table bk_full_profile(ID INTEGER PRIMARY KEY, MINUTE TEXT, HOUR TEXT, DAY TEXT, MONTH TEXT, WEEK TEXT)'

sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(1, 0, 6, "*", "*", 1);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(2, 10, 6, "*", "*", 1);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(3, 20, 6, "*", "*", 1);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(4, 30, 6, "*", "*", 1);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(5, 40, 6, "*", "*", 1);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(6, 50, 6, "*", "*", 1);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(7, 0, 7, "*", "*", 1);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(8, 0, 6, "*", "*", 2);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(9, 10, 6, "*", "*", 2);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(10, 20, 6, "*", "*", 2);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(11, 30, 6, "*", "*", 2);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(12, 40, 6, "*", "*", 2);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(13, 50, 6, "*", "*", 2);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(14, 0, 7, "*", "*", 2);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(15, 0, 6, "*", "*", 3);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(16, 10, 6, "*", "*", 3);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(17, 20, 6, "*", "*", 3);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(18, 30, 6, "*", "*", 3);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(19, 40, 6, "*", "*", 3);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(20, 50, 6, "*", "*", 3);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(21, 0, 7, "*", "*", 3);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(22, 0, 6, "*", "*", 4);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(23, 10, 6, "*", "*", 4);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(24, 20, 6, "*", "*", 4);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(25, 30, 6, "*", "*", 4);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(26, 40, 6, "*", "*", 4);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(27, 50, 6, "*", "*", 4);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(28, 0, 7, "*", "*", 4);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(29, 0, 6, "*", "*", 5);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(30, 10, 6, "*", "*", 5);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(31, 20, 6, "*", "*", 5);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(32, 30, 6, "*", "*", 5);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(33, 40, 6, "*", "*", 5);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(34, 50, 6, "*", "*", 5);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(35, 0, 7, "*", "*", 5);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(36, 0, 6, "*", "*", 6);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(37, 10, 6, "*", "*", 6);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(38, 20, 6, "*", "*", 6);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(39, 30, 6, "*", "*", 6);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(40, 40, 6, "*", "*", 6);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(41, 50, 6, "*", "*", 6);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(42, 0, 7, "*", "*", 6);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(43, 0, 6, "*", "*", 7);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(44, 10, 6, "*", "*", 7);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(45, 20, 6, "*", "*", 7);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(46, 30, 6, "*", "*", 7);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(47, 40, 6, "*", "*", 7);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(48, 50, 6, "*", "*", 7);'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_full_profile values(49, 0, 7, "*", "*", 7);'

# For Instant Backup
# [ MON - SUN / 3am - 5:50am ] Everyday / Every 10 minutes
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 \
    'create table bk_instant_profile(ID INTEGER PRIMARY KEY, MINUTE TEXT, HOUR TEXT, DAY TEXT, MONTH TEXT, WEEK TEXT)'

sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(1, 0, 3, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(2, 10, 3, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(3, 20, 3, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(4, 30, 3, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(5, 40, 3, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(6, 50, 3, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(7, 0, 4, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(8, 10, 4, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(9, 20, 4, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(10, 30, 4, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(11, 40, 4, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(12, 50, 4, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(13, 0, 5, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(14, 10, 5, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(15, 20, 5, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(16, 30, 5, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(17, 40, 5, "*", "*", "*");'
sqlite3 /var/lib/mcsoc/cron-profile.sqlite3 'insert into bk_instant_profile values(18, 50, 5, "*", "*", "*");'