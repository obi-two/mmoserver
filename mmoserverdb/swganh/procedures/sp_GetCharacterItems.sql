/*
---------------------------------------------------------------------------------------
This source file is part of SWG:ANH (Star Wars Galaxies - A New Hope - Server Emulator)

For more information, visit http://www.swganh.com

Copyright (c) 2006 - 2010 The SWG:ANH Team
---------------------------------------------------------------------------------------
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
---------------------------------------------------------------------------------------
*/

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

use swganh;

--
-- Definition of procedure `sp_GetCharacterItems`
--

DELIMITER $$

DROP PROCEDURE IF EXISTS `sp_GetCharacterItems` $$

/*!50003 SET @TEMP_SQL_MODE=@@SQL_MODE, SQL_MODE='' */ $$

CREATE PROCEDURE `sp_GetCharacterItems`(IN inventory_id BIGINT(20)) SQL SECURITY INVOKER
BEGIN
  SELECT DISTINCT 'item', t1.id FROM items AS t1
    LEFT JOIN items AS t2 ON t2.parent_id = t1.id
    LEFT JOIN items AS t3 ON t3.parent_id = t2.id
    LEFT JOIN items AS t4 ON t4.parent_id = t3.id
    WHERE t1.parent_id = inventory_id
  UNION ALL
  SELECT 'resource', id FROM `resource_containers` WHERE parent_id = ANY (SELECT DISTINCT t1.id FROM items AS t1
    LEFT JOIN items AS t2 ON t2.parent_id = t1.id
    LEFT JOIN items AS t3 ON t3.parent_id = t2.id
    LEFT JOIN items AS t4 ON t4.parent_id = t3.id
    WHERE t1.parent_id = inventory_id)
  UNION ALL
  SELECT DISTINCT 'item',t2.id FROM items AS t1
    LEFT JOIN items AS t2 ON t2.parent_id = t1.id
    LEFT JOIN items AS t3 ON t3.parent_id = t2.id
    LEFT JOIN items AS t4 ON t4.parent_id = t3.id
    WHERE t1.parent_id = inventory_id
  UNION ALL
  SELECT 'resource', id FROM `resource_containers` WHERE parent_id = ANY (SELECT DISTINCT t2.id FROM items AS t1
    LEFT JOIN items AS t2 ON t2.parent_id = t1.id
    LEFT JOIN items AS t3 ON t3.parent_id = t2.id
    LEFT JOIN items AS t4 ON t4.parent_id = t3.id
    WHERE t1.parent_id = inventory_id)
  UNION ALL
  SELECT DISTINCT 'item',t3.id FROM items AS t1
    LEFT JOIN items AS t2 ON t2.parent_id = t1.id
    LEFT JOIN items AS t3 ON t3.parent_id = t2.id
    LEFT JOIN items AS t4 ON t4.parent_id = t3.id
    WHERE t1.parent_id = inventory_id
  UNION ALL
  SELECT 'resource', id FROM `resource_containers` WHERE parent_id = ANY (SELECT DISTINCT t3.id FROM items AS t1
    LEFT JOIN items AS t2 ON t2.parent_id = t1.id
    LEFT JOIN items AS t3 ON t3.parent_id = t2.id
    LEFT JOIN items AS t4 ON t4.parent_id = t3.id
    WHERE t1.parent_id = inventory_id)
  UNION ALL
  SELECT DISTINCT 'item',t4.id FROM items AS t1
    LEFT JOIN items AS t2 ON t2.parent_id = t1.id
    LEFT JOIN items AS t3 ON t3.parent_id = t2.id
    LEFT JOIN items AS t4 ON t4.parent_id = t3.id
  WHERE t1.parent_id = inventory_id
  UNION ALL
  SELECT 'resource', id FROM `resource_containers` WHERE parent_id = ANY (SELECT DISTINCT t4.id FROM items AS t1
    LEFT JOIN items AS t2 ON t2.parent_id = t1.id
    LEFT JOIN items AS t3 ON t3.parent_id = t2.id
    LEFT JOIN items AS t4 ON t4.parent_id = t3.id
  WHERE t1.parent_id = inventory_id);

END $$

/*!50003 SET SESSION SQL_MODE=@TEMP_SQL_MODE */  $$

DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;