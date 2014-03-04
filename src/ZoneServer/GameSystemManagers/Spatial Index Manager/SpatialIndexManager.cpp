/*
---------------------------------------------------------------------------------------
This source file is part of SWG:ANH (Star Wars Galaxies - A New Hope - Server Emulator)

For more information, visit http://www.swganh.com

Copyright (c) 2006 - 2014 The SWG:ANH Team
---------------------------------------------------------------------------------------
Use of this source code is governed by the GPL v3 license that can be found
in the COPYING file or at http://www.gnu.org/licenses/gpl-3.0.html

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

#include <cassert>
#include <algorithm>

#include "ZoneServer/GameSystemManagers/Spatial Index Manager/SpatialIndexManager.h"
#include "ZoneServer/GameSystemManagers/Structure Manager/BuildingObject.h"
#include "ZoneServer/GameSystemManagers/Structure Manager/CellObject.h"
#include "ZoneServer/GameSystemManagers/Structure Manager/PlayerStructure.h"
#include "ZoneServer/GameSystemManagers/Container Manager/ContainerManager.h"
#include "ZoneServer/GameSystemManagers/Structure Manager/FactoryCrate.h"
#include "ZoneServer/GameSystemManagers/Structure Manager/FactoryObject.h"
#include "ZoneServer/GameSystemManagers/Structure Manager/HouseObject.h"
#include "ZoneServer/Objects/MountObject.h"
#include "ZoneServer/Objects/Player Object/PlayerObject.h"

#include "ZoneServer/Objects/RegionObject.h"
#include "ZoneServer/WorldManager.h"
#include "ZoneServer/ZoneOpcodes.h"
#include "ZoneServer/ZoneServer.h"

//======================================================================================================================

bool					SpatialIndexManager::mInsFlag    = false;
SpatialIndexManager*	SpatialIndexManager::mSingleton  = NULL;
//======================================================================================================================


SpatialIndexManager*	SpatialIndexManager::Init(swganh::database::Database* database)
{
    if(!mInsFlag)
    {
        mSingleton = new SpatialIndexManager();
        mInsFlag = true;
        return mSingleton;
    }
    else
        return mSingleton;
}

void SpatialIndexManager::Shutdown()
{
    delete(mSpatialGrid);
}

SpatialIndexManager::SpatialIndexManager()
{
    mSpatialGrid = new zmap();
    gMessageLib->setGrid(mSpatialGrid);

}

/*=================================================
*adds a new object to the grid
*creates the object for all players in range
*if object is a player all objects in range will be created
*/

bool SpatialIndexManager::_AddObject(Object *newObject)
{

	uint64 parent_id = newObject->getParentId();
	Object* object = gWorldManager->getObjectById(parent_id);
	if(object && object->getObjectType() == SWG_CELL)	{
		DLOG(error) << "SpatialIndexManager::_AddObject - we do NOT add the content of cells to the grid!!";
		return false;
	}

    uint32 finalBucket = getGrid()->AddObject(newObject);

    //DLOG(info) << "SpatialIndexManager::AddObject :: Object " << newObject->getId() << " added to bucket " <<  finalBucket;

    if(finalBucket == 0xffffffff)    {
        DLOG(info) << "SpatialIndexManager::AddObject :: Object " << newObject->getId() << " could not be added to the bucket because the bucket was invalid " <<  finalBucket;
        return false;
    }
   
	//get all Players in range and register as necessary
    ObjectListType playerList;
    getGrid()->GetPlayerViewingRangeCellContents(finalBucket, &playerList);

    for(ObjectListType::iterator i = playerList.begin(); i != playerList.end(); i++)    {
        PlayerObject* foundPlayer = static_cast<PlayerObject*>((*i));
        sendCreateObject(newObject,foundPlayer, false);
		
		//lets register the player as a watcher and add our children to his watch list
        if((newObject->getType() == ObjType_Creature) || (newObject->getType() == ObjType_NPC))	{
            gContainerManager->registerPlayerToContainer(newObject, foundPlayer);
        }
    }

    return true;
}

bool SpatialIndexManager::_AddObject(PlayerObject *player)
{

	uint32 finalBucket = getGrid()->AddObject(player->GetCreature());

    DLOG(info) << "SpatialIndexManager::AddObject :: Player " << player->getId() << " added to bucket " <<  finalBucket;

    //now create it for everyone around and around for it

    ObjectListType playerList;
    getGrid()->GetViewingRangeCellContents(finalBucket, &playerList,(Bucket_Creatures|Bucket_Objects|Bucket_Players));

    for(ObjectListType::iterator i = playerList.begin(); i != playerList.end(); i++)    {
        //we just added ourselves to the grid - dont send a create to ourselves
        if(((*i)->getId() == player->getId()))		{
			//we want to be updated about ourselves
            player->registerWatcher(player);
			//cave that sends creates
			//gContainerManager->registerPlayerToContainer((*i), player);
			continue;
        }

        //the object needs to be created no matter what
        sendCreateObject((*i), player, false);

		//we only register us to creatures - NOT to buildings
        if(((*i)->getType() == ObjType_Creature) || ((*i)->getType() == ObjType_NPC))	{
            gContainerManager->registerPlayerToContainer((*i), player);
            continue;
        }

        if((*i)->getType() == ObjType_Player) 		{
			//create us for the other player
            PlayerObject* otherPlayer = static_cast<PlayerObject*>(*i);
            sendCreateObject(player, otherPlayer, false);

            gContainerManager->registerPlayerToContainer(otherPlayer, player);
			gContainerManager->registerPlayerToContainer(player, otherPlayer);
            continue;
        }
    }
    return true;
}

void SpatialIndexManager::UpdateObject(Object *updateObject)
{

    uint32 oldBucket = updateObject->getGridBucket();
    uint32 newBucket = getGrid()->getCellId(updateObject->getWorldPosition().x, updateObject->getWorldPosition().z);

    // now process the spatial index update
    if(newBucket != oldBucket)	{
        DLOG(info) << "ContainerManager::UpdateObject :: " << updateObject->getId() <<"normal movement from bucket" << oldBucket << " to bucket" << newBucket;
        
        // test how much we moved if only one grid proceed normally
        if((newBucket == (oldBucket +1)) || (newBucket == (oldBucket -1)) ||
           (newBucket == (oldBucket + GRIDWIDTH)) || (newBucket == (oldBucket - GRIDWIDTH))	 ||
           (newBucket == (oldBucket + GRIDWIDTH +1)) || (newBucket == (oldBucket + GRIDWIDTH -1)) ||
           (newBucket == (oldBucket - GRIDWIDTH +1)) || (newBucket == (oldBucket - GRIDWIDTH -1)))	{
            // sets the new gridcell, updates subcells
            getGrid()->UpdateObject(updateObject);

            // remove us from the row we left
            _UpdateBackCells(updateObject,oldBucket);

            // create us for the row in which direction we moved
            _UpdateFrontCells(updateObject,oldBucket);
        } else {
            // we teleported destroy all and create everything new
            DLOG(info) << "ContainerManager::UpdateObject :: " << updateObject->getId() <<"teleportation from bucket" << oldBucket << " to bucket" << newBucket;

            // remove us from everything
            RemoveObjectFromWorld(updateObject);

            // and add us freshly to the world
            _AddObject(updateObject);
        }
    }
    
    // Make sure to update any regions the object may be entering or leaving.
    getGrid()->updateRegions(updateObject);
}



void SpatialIndexManager::RemoveRegion(std::shared_ptr<RegionObject> remove_region)
{
	getGrid()->RemoveRegion(remove_region->getId());
}

void SpatialIndexManager::addRegion(std::shared_ptr<RegionObject> region)
{
    //add the adequate subcells to the grid
    getGrid()->addRegion(region);
}

std::shared_ptr<RegionObject> SpatialIndexManager::findRegion(uint64_t id) {
    return getGrid()->findRegion(id);
}

//*********************************************************************
//a simple Object can only be in the grid *or* in the cell or in the inventory or in a container
//it can be equipped however by a creature / player
void SpatialIndexManager::RemoveObjectFromWorld(Object *removeObject)
{

    DLOG(info) << "SpatialIndexManager::RemoveObjectFromWorld:: Object : " << removeObject->getId();

    //were in a container - get us out
    if(removeObject->getParentId())	{
        Object* container = gWorldManager->getObjectById(removeObject->getParentId());
        if(container)	{
            //update the world on our changes
            gContainerManager->destroyObjectToRegisteredPlayers(container,removeObject->getId());

            //remove the object out of the container
            container->RemoveObject(container, removeObject);
        }

        //no need to remove a tangible(!) from the grid if it was in a cell
        return;
    }

    //if we are a building we need to prepare for destruction
    BuildingObject* building = dynamic_cast<BuildingObject*>(removeObject);
    if(building)	{
        building->prepareDestruction();
    }

    //remove it out of the grid
    _RemoveObjectFromGrid(removeObject);
	DLOG(info) << "SpatialIndexManager::RemoveObjectFromWorld:: done : ";
}

//*********************************************************************
//a Player or creature is ALWAYS in the grid and possibly in a cell
void SpatialIndexManager::RemoveObjectFromWorld(PlayerObject *removePlayer)
{
    DLOG(info) << "SpatialIndexManager::RemoveObjectFromWorld:: Player : " << removePlayer->getId();

    //remove us from the grid
    _RemoveObjectFromGrid(removePlayer);

    //remove us out of the cell
    if(removePlayer->getParentId() == 0)	{
        return;
    }

    CellObject* cell = dynamic_cast<CellObject*>(gWorldManager->getObjectById(removePlayer->getParentId()));
    if(!cell)    {
		DLOG(info) << "SpatialIndexManager::RemoveObjectFromWorld (player): couldn't find cell " << removePlayer->getParentId();
		return;
	}
    //unregister from the building and all its cells
    if(BuildingObject* building = dynamic_cast<BuildingObject*>(gWorldManager->getObjectById(cell->getParentId())))		{
        gContainerManager->unRegisterPlayerFromBuilding(building,removePlayer);
    }

    cell->RemoveObject(cell, removePlayer);

}

void SpatialIndexManager::RemoveObjectFromWorld(CreatureObject *removeCreature)
{
    DLOG(info) << "SpatialIndexManager::RemoveObjectFromWorld:: Creature : " << removeCreature->getId();

    //remove us from the grid
    _RemoveObjectFromGrid(removeCreature);

    //remove us out of the cell
    Object* container = gWorldManager->getObjectById(removeCreature->getParentId());
    if(container)
    {
        gContainerManager->destroyObjectToRegisteredPlayers(container,removeCreature->getId());

        //remove the object out of the container
        container->RemoveObject(container, removeCreature);
    }


}


//===========================================================================
// this will remove an object from the grid
// if the object is a container with listeners, the listeners will be unregistered
// SpatialIndexManager::UpdateObject calls us with updateGrid = false in case we teleported
// we have updated the grid in that case already
void SpatialIndexManager::_RemoveObjectFromGrid(Object *removeObject)
{

    uint32 bucket = removeObject->getGridBucket();

    DLOG(info) << "SpatialIndexManager::RemoveObject:: : " << removeObject->getId() << "out of Bucket : " << bucket;

    //remove out of grid lists
	if((bucket == 0xffffffff) || (!getGrid()->RemoveObject(removeObject)))	{
		//we  arnt part of the world
		DLOG(info) << "SpatialIndexManager::RemoveObject:: : " << removeObject->getId() << " wasnt part of the simulation";
		return;
	}

    //get the Objects and unregister as necessary
    ObjectListType playerList;

	//Objects are interested in players only
	//players interested in everything
	uint32 bucket_type = (Bucket_Creatures|Bucket_Objects|Bucket_Players);
	if(removeObject->getType() != ObjType_Player)	{
		bucket_type = (Bucket_Players);
	}
  
    getGrid()->GetViewingRangeCellContents(bucket, &playerList, bucket_type);

    for(ObjectListType::iterator i = playerList.begin(); i != playerList.end(); i++)
    {
    
        //if we are a watcher (player) unregister us from everything around us
		if(removeObject->getType() == ObjType_Player)	{
			PlayerObject* removePlayer = static_cast<PlayerObject*>(removeObject);
          
			//start with destroying our surroundings for us
			gMessageLib->sendDestroyObject((*i)->getId(), removePlayer);

			//now unregister us from any container
			gContainerManager->unRegisterPlayerFromContainer((*i), removePlayer);
			if((*i)->getType() == ObjType_Player)	{
				PlayerObject* otherPlayer = static_cast<PlayerObject*>((*i));
				gMessageLib->sendDestroyObject(removeObject->getId(), otherPlayer );
			}
			
        }
		//we are an object - unregister us from players around us
        else		{
            //is the object a container?? do we need to despawn the content and unregister it ?
            //just dont unregister us for ourselves or our equipment - we likely only travel
            if((*i)->getType() == ObjType_Player)	{
                PlayerObject* otherPlayer = static_cast<PlayerObject*>((*i));
				gMessageLib->sendDestroyObject(removeObject->getId(), otherPlayer );
                gContainerManager->unRegisterPlayerFromContainer(removeObject, otherPlayer);
            }
		}
    }

	//go through container registrations of tangibles for containers we still now
	//these probably will be our player (if we are a hair)
	//or our hair if we are a player
	//all players should be taken care of at this point
    PlayerObjectSet* knownPlayers	= removeObject->getRegisteredWatchers();
    PlayerObjectSet::iterator it	= knownPlayers->begin();

    while(it != knownPlayers->end())    {
        //the only registration a player is still supposed to have at this point is himself and his inventory and hair
		LOG (info) << "SpatialIndexManager::_RemoveObjectFromGrid " << (*it)->getId() << " is still known to player : " << removeObject->getId();
        PlayerObject* const player = static_cast<PlayerObject*>(*it);
        
		if(player->getId() != removeObject->getId())        {
       
            //unRegisterPlayerFromContainer invalidates the knownPlayer iterator
            gContainerManager->unRegisterPlayerFromContainer(removeObject, player);
			
			PlayerObject* const remove_player = static_cast<PlayerObject*>(removeObject);
			if(remove_player)	{
				gMessageLib->sendDestroyObject(player->getId(), remove_player);
			}
			
			gMessageLib->sendDestroyObject(remove_player->getId(),player);
            
			it = knownPlayers->begin();
        }
        else
			it++;
    }

}

// when a player leaves a structure we need to either delete all items in the structure directly
// or cache them until the structure gets deleted

void SpatialIndexManager::removePlayerFromStructure(PlayerObject* player, CellObject* cell)
{
    BuildingObject* building = dynamic_cast<BuildingObject*>(gWorldManager->getObjectById(cell->getParentId()));
    if(building)    {
        //for now delete the content directly
        removeStructureItemsForPlayer(player, building);
    }

}

//=========================================================================================
//
// removes all structures items for a player
// call this when destroying a building
//
void SpatialIndexManager::removeStructureItemsForPlayer(PlayerObject* player, BuildingObject* building)
{
    DLOG(info) << "SpatialIndexManager::removeStructureItemsForPlayer:: : " << player->getId();

    ObjectList cellObjects		= building->getAllCellChilds();
    ObjectList::iterator objIt	= cellObjects.begin();

    while(objIt != cellObjects.end())	{
        Object* object = (*objIt);
		//do not destroy static cells / items that are in the tres
		if(object->getId() <= 4294967296)	{
			DLOG(info) << "SpatialIndexManager::_CheckObjectIterationForDestruction :: prevented static from being destroyed";
			continue;
		}

        if(PlayerObject* otherPlayer = dynamic_cast<PlayerObject*>(object))	{
            //do nothing players and creatures are always in the grid
        }
        else if(CreatureObject* pet = dynamic_cast<CreatureObject*>(object))	{
            //do nothing players and creatures are always in the grid
        }
        else	{
            if((object) && (object->checkRegisteredWatchers(player)))	{
                gContainerManager->unRegisterPlayerFromContainer(object,player);
				gMessageLib->sendDestroyObject(object->getId(), player);
            }
        }
        objIt++;
    }


}

//============================================================================
//destroy toBeTested for updateObject
// unregister containers

void SpatialIndexManager::_CheckObjectIterationForDestruction(Object* toBeTested, Object* updatedObject)
{
    //DLOG(info) << "SpatialIndexManager::_CheckObjectIterationForDestruction (Player) :: check : " <<toBeTested->getId() << " to be removed from " << toBeUpdated->getId();
	//remove updateObject from toBeTested watcher list in case updateObject is a player

	//do not destroy static cells / items that are in the tres
	if(toBeTested->getId() <= 4294967296)	{
		DLOG(info) << "SpatialIndexManager::_CheckObjectIterationForDestruction :: prevented static from being destroyed";
		return;
	}

	if(updatedObject->getType() == ObjType_Player)	{ 
		PlayerObject* updatedPlayer = static_cast<PlayerObject*>(updatedObject);
		
		gContainerManager->unRegisterPlayerFromContainer(toBeTested,updatedPlayer);
		
		//we (updateObject) got out of range of toBeTested
		gMessageLib->sendDestroyObject(toBeTested->getId(),updatedPlayer);
		

		if(toBeTested->getType() == ObjType_Player)    {
			DLOG(info) << "SpatialIndexManager::_CheckObjectIterationForDestruction (Player) :: check Player : " <<toBeTested->getId() << " to be removed from Player : " << updatedObject->getId();
		}		
	}    

    //if its a player, destroy us for him
    if(toBeTested->getType() == ObjType_Player)    {
        PlayerObject* testedPlayer = static_cast<PlayerObject*> (toBeTested);
        gContainerManager->unRegisterPlayerFromContainer(updatedObject,testedPlayer);
		gMessageLib->sendDestroyObject(updatedObject->getId(),testedPlayer);
    }
}


//=================================================================================
//destroy objects out of our range when moving for ONE GRID
//do not use when teleporting
//

void SpatialIndexManager::_UpdateBackCells(Object* updateObject, uint32 oldCell)
{

	DLOG(info) << "SpatialIndexManager::_UpdateBackCells OldCell " << oldCell << " NewCell : " << updateObject->getGridBucket();

    uint32 newCell = updateObject->getGridBucket();

    //Update all for players
    uint32 queryType = Bucket_Creatures | Bucket_Objects | Bucket_Players;

    //npcs/ creatures are only interested in updating players
    if(updateObject->getType() != ObjType_Player)    {
        queryType = Bucket_Players;
    }

    //ZMAP Northbound!
    if((oldCell + GRIDWIDTH) == newCell)    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetGridContentsListRow(oldCell - (GRIDWIDTH*VIEWRANGE), &FinalList, queryType);

        for(ObjectListType::iterator i = FinalList.begin(); i != FinalList.end(); i++)	{
            _CheckObjectIterationForDestruction((*i),updateObject);
        }

        return;
    }

    //ZMAP Southbound!
    else if((oldCell - GRIDWIDTH) == newCell)    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetGridContentsListRow(oldCell + (GRIDWIDTH*VIEWRANGE), &FinalList, queryType);

        for(ObjectListType::iterator i = FinalList.begin(); i != FinalList.end(); i++)	{
            _CheckObjectIterationForDestruction((*i),updateObject);
        }

        return;
    }

    //ZMAP Westbound!
    else if((oldCell - 1) == newCell)    {

        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetGridContentsListColumn(oldCell + VIEWRANGE, &FinalList, queryType);

        for(ObjectListType::iterator it = FinalList.begin(); it != FinalList.end(); it++)	{
            _CheckObjectIterationForDestruction((*it),updateObject);
        }

        return;
    }

    //Eastbound!
    else if((oldCell + 1) == newCell)    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetGridContentsListColumn(oldCell - VIEWRANGE, &FinalList, queryType);


        for(ObjectListType::iterator i = FinalList.begin(); i != FinalList.end(); i++)	{
            _CheckObjectIterationForDestruction((*i),updateObject);
        }

        return;
    }

    // NorthEastbound
    else if((oldCell + (GRIDWIDTH+1)) == newCell)
    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetCellContents(oldCell - (GRIDWIDTH+1)*VIEWRANGE, &FinalList, queryType);
        getGrid()->GetGridContentsListColumnUp(oldCell - ((GRIDWIDTH+1)*VIEWRANGE) +GRIDWIDTH, &FinalList, queryType);
        getGrid()->GetGridContentsListRowRight(oldCell - ((GRIDWIDTH+1)*VIEWRANGE) + 1, &FinalList, queryType);//

        for(ObjectListType::iterator i = FinalList.begin(); i != FinalList.end(); i++)	{
            _CheckObjectIterationForDestruction((*i),updateObject);
        }

        return;
    }

    // NorthWestbound -> up left
    else if((oldCell + GRIDWIDTH-1) == newCell)
    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        //so we need to delete down right (Southeast)
        getGrid()->GetCellContents(oldCell - ((GRIDWIDTH-1)*VIEWRANGE), &FinalList, queryType);
        getGrid()->GetGridContentsListColumnUp(oldCell - ((GRIDWIDTH-1)*VIEWRANGE) +GRIDWIDTH, &FinalList, queryType);
        getGrid()->GetGridContentsListRowLeft(oldCell - ((GRIDWIDTH-1)*VIEWRANGE)-1, &FinalList, queryType);//

        for(ObjectListType::iterator i = FinalList.begin(); i != FinalList.end(); i++)	{
            _CheckObjectIterationForDestruction((*i),updateObject);
        }

        return;
    }

    // SouthWestbound	  -> down left
    else if((oldCell - (GRIDWIDTH+1)) == newCell)
    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        //so we need to delete up right (Northeast)
        getGrid()->GetCellContents(oldCell + (GRIDWIDTH+1)*VIEWRANGE, &FinalList, queryType);
        getGrid()->GetGridContentsListColumnDown(oldCell + ((GRIDWIDTH+1)*VIEWRANGE) - GRIDWIDTH, &FinalList, queryType);
        getGrid()->GetGridContentsListRowLeft(oldCell + ((GRIDWIDTH+1)*VIEWRANGE) -1, &FinalList, queryType);//

        for(ObjectListType::iterator i = FinalList.begin(); i != FinalList.end(); i++)	{
            _CheckObjectIterationForDestruction((*i),updateObject);
        }

        return;
    }

    // SouthEastbound	-> down right
    else if((oldCell - (GRIDWIDTH-1)) == newCell)
    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        //so we need to delete up left (Northwest)
        getGrid()->GetCellContents(oldCell + ((GRIDWIDTH-1)*VIEWRANGE), &FinalList, queryType);
        getGrid()->GetGridContentsListColumnDown(oldCell + ((GRIDWIDTH-1)*VIEWRANGE) -GRIDWIDTH, &FinalList, queryType);
        getGrid()->GetGridContentsListRowRight(oldCell + ((GRIDWIDTH-1)*VIEWRANGE) +1, &FinalList, queryType);//

        for(ObjectListType::iterator i = FinalList.begin(); i != FinalList.end(); i++)	{
            _CheckObjectIterationForDestruction((*i),updateObject);
        }

        return;
    }

}



//=============================================================================================
//collect Objects in the new cells
void SpatialIndexManager::_UpdateFrontCells(Object* updateObject, uint32 oldCell)
{
    uint32 newCell = updateObject->getGridBucket();

    //Update all for players
    uint32 queryType = Bucket_Creatures | Bucket_Objects | Bucket_Players;

    //npcs/ creatures are only interested in updating players
    if(updateObject->getType() != ObjType_Player)    {
        queryType = Bucket_Players;
    }

    //ZMAP Northbound!
    if((oldCell + GRIDWIDTH) == newCell)    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetGridContentsListRow((newCell + (GRIDWIDTH*VIEWRANGE)) , &FinalList, queryType);

        _ObjectCreationIteration(&FinalList,updateObject);

        return;
    }

    //ZMAP Southbound!
    else if((oldCell - GRIDWIDTH) == newCell)
    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetGridContentsListRow((newCell - (GRIDWIDTH*VIEWRANGE)) , &FinalList, queryType);

        _ObjectCreationIteration(&FinalList,updateObject);

        return;
    }

    //ZMAP Eastbound!
    else if((oldCell + 1) == newCell)
    {

        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetGridContentsListColumn((newCell + VIEWRANGE) , &FinalList, queryType);

        _ObjectCreationIteration(&FinalList,updateObject);

        return;
    }

    //ZMAP Westbound!
    else if((oldCell - 1) == newCell)
    {

        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetGridContentsListColumn((newCell - VIEWRANGE) , &FinalList, queryType);

        _ObjectCreationIteration(&FinalList,updateObject);

        return;
    }

    // NorthEastbound
    else if((oldCell + (GRIDWIDTH+1)) == newCell)
    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetCellContents((newCell + ((GRIDWIDTH+1)*VIEWRANGE)) , &FinalList, queryType);//

        getGrid()->GetGridContentsListColumnDown((updateObject->getGridBucket() + ((GRIDWIDTH+1)*VIEWRANGE)) - GRIDWIDTH, &FinalList, queryType);//

        getGrid()->GetGridContentsListRowLeft((updateObject->getGridBucket() + ((GRIDWIDTH+1)*VIEWRANGE+1)) - 1, &FinalList, queryType);//

        _ObjectCreationIteration(&FinalList,updateObject);

        return;
    }

    // NorthWestbound
    else if((oldCell + (GRIDWIDTH-1)) == newCell)
    {
        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetCellContents((updateObject->getGridBucket() + ((GRIDWIDTH-1)*VIEWRANGE)) , &FinalList, queryType);//

        getGrid()->GetGridContentsListColumnDown((updateObject->getGridBucket() + ((GRIDWIDTH-1)*VIEWRANGE))  - GRIDWIDTH, &FinalList, queryType);//

        getGrid()->GetGridContentsListRowRight((updateObject->getGridBucket() + ((GRIDWIDTH-1)*VIEWRANGE))   + 1, &FinalList, queryType);//

        _ObjectCreationIteration(&FinalList,updateObject);

        return;
    }

    // SouthWestbound
    else if((oldCell - (GRIDWIDTH+1)) == newCell)
    {

        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetCellContents((updateObject->getGridBucket() - ((GRIDWIDTH+1)*VIEWRANGE)) , &FinalList, queryType);

        getGrid()->GetGridContentsListColumnUp((updateObject->getGridBucket() - ((GRIDWIDTH+1)*VIEWRANGE))  + GRIDWIDTH, &FinalList, queryType);

        getGrid()->GetGridContentsListRowRight((updateObject->getGridBucket() - ((GRIDWIDTH+1)*VIEWRANGE))  + 1, &FinalList, queryType);//

        _ObjectCreationIteration(&FinalList,updateObject);

        return;
    }

    // SouthEastbound
    else if((oldCell - (GRIDWIDTH-1)) == newCell)
    {

        ObjectListType FinalList;
        ObjectListType::iterator it;

        getGrid()->GetCellContents((updateObject->getGridBucket() - (GRIDWIDTH-1)*VIEWRANGE) , &FinalList, queryType);

        getGrid()->GetGridContentsListColumnUp((updateObject->getGridBucket() - ((GRIDWIDTH-1)*VIEWRANGE))  + GRIDWIDTH, &FinalList, queryType);

        getGrid()->GetGridContentsListRowLeft((updateObject->getGridBucket() - ((GRIDWIDTH-1)*VIEWRANGE))  - 1, &FinalList, queryType);//

        _ObjectCreationIteration(&FinalList,updateObject);

        return;
    }
}

//======================================================================================================
// iterate through all Objects and create them and register them as necessary
void SpatialIndexManager::_ObjectCreationIteration(std::list<Object*>* FinalList, Object* updateObject)
{

    for(std::list<Object*>::iterator i = FinalList->begin(); i != FinalList->end(); i++)	{
        _CheckObjectIterationForCreation((*i),updateObject);
    }
}

//================================================================================================
// this is called for players and creatures / NPCs alike
//
void SpatialIndexManager::_CheckObjectIterationForCreation(Object* toBeTested, Object* updatedObject)
{
    if(toBeTested->getId() == updatedObject->getId())	{
        LOG(error) << "_CheckObjectIterationForCreation :: we shouldnt iterate to create ourselves";
			return;
    }

    //we are a player and need to create the following object for us
	if(updatedObject->getType() == ObjType_Player)	{
		
		PlayerObject* updatedPlayer = static_cast<PlayerObject*>(updatedObject);
        sendCreateObject(toBeTested,updatedPlayer,false);

        if(toBeTested->getType() == ObjType_NPC || toBeTested->getType() == ObjType_Creature)	{
            gContainerManager->registerPlayerToContainer(toBeTested, updatedPlayer);
        }
    }

	if(toBeTested->getType() == ObjType_Player)	{
		PlayerObject* testedPlayer = static_cast<PlayerObject*> (toBeTested);
        sendCreateObject(updatedObject,testedPlayer,false);
        gContainerManager->registerPlayerToContainer(updatedObject, testedPlayer);
    }

}


void SpatialIndexManager::createInWorld(CreatureObject* creature)
{
    this->_AddObject(creature);

    //are we in a cell? otherwise bail out
    if(creature->getParentId() == 0)	{
        return;
    }

    CellObject* cell = dynamic_cast<CellObject*>(gWorldManager->getObjectById(creature->getParentId()));
    if(!cell)	{
       //assert(false && "SpatialIndexManager::createInWorld cannot cast cell ???? ");
        return;
    }

    BuildingObject* building = dynamic_cast<BuildingObject*>(gWorldManager->getObjectById(cell->getParentId()));
    if(!building)	{
        assert(false && "SpatialIndexManager::createInWorld cannot cast building ???? ");
        return;
    }

    //add the Creature to the cell we are in
    cell->AddObject(cell, creature);
}


void SpatialIndexManager::createInWorld(PlayerObject* player)
{
    //just create in the SI - it will keep track of nearby players
    this->_AddObject(player);

    //are we in a cell? otherwise bail out
    if(player->getParentId() == 0)	{
        return;
    }

    CellObject* cell = dynamic_cast<CellObject*>(gWorldManager->getObjectById(player->getParentId()));
    if(!cell)	{
		LOG(error) << "db integrity error! character : " << player->getId() << "in wrong container : " << player->getParentId();
        return;
    }

    BuildingObject* building = dynamic_cast<BuildingObject*>(gWorldManager->getObjectById(cell->getParentId()));
    if(!building)	{
        LOG(error) << "db integrity error! character : " << player->getId() << "in container : " << player->getParentId() << "cannot find building : " << cell->getParentId();
        return;
    }

    //we *should* already be registered as known watcher to the building

    //add the Creature to the cell we are in
    if(!cell->AddObject(player, player))	{
		//if we are thrown out (building now private or whatever)
		player->mPosition = building->mPosition;
		player->mPosition.x += 10;
		player->setParentId(0);
		this->UpdateObject(player);
		return;
	}

    //iterate through all the cells and add the player as listener
	building->ViewObjects(player, 0, false, [&](Object* object){
		gContainerManager->registerPlayerToContainer(object, player);
	});
    
}

void SpatialIndexManager::createInWorld(Object* object)
{
    uint32 baseCell = 0xffffffff;

    //get parent object determine who to send creates for

    if(object->getParentId() == 0)    {
        //just create in the SI - it will keep track of nearby players
        this->_AddObject(object);
        return;
    }

    Object* parent = gWorldManager->getObjectById(object->getParentId());

    //start with equipped items
	if(!parent)    {
		LOG(error) << "SpatialIndexManager::createInWorld : no valid parent";
		return;
	}
	
	parent->AddObject(object);
    gContainerManager->createObjectToRegisteredPlayers(parent, object);

}

//======================================================================================================================
// when creating a player and the player is in a cell we need to create all the cells contents for the player
// cellcontent is *NOT* in the grid



void SpatialIndexManager::initObjectsInRange(PlayerObject* player) {
    uint64_t player_id = player->getParentId();
    if (player_id == 0) {
        return;
    }

    Object* tmp = gWorldManager->getObjectById(player_id);
    if (tmp->getType() != ObjType_Cell) {
        return;
    }

    CellObject* cell = static_cast<CellObject*>(tmp);

    tmp = gWorldManager->getObjectById(cell->getParentId());
    if (tmp->getType() != ObjType_Building) {
        return;
    }

    BuildingObject* building = static_cast<BuildingObject*>(tmp);

    ObjectList children = building->getAllCellChilds();

    std::for_each(children.begin(), children.end(), [this, player] (Object* cell_child) {
        if (cell_child->getType() != ObjType_Tangible) {
            return;
        }

        sendCreateObject(cell_child, player, true);
    });
}

//==============================================================================================================
//
// get the Objects in range of the player ie everything in the Object Bucket
// NO players, NO creatures, NO regions
//
void SpatialIndexManager::getObjectsInRange(const Object* const object, ObjectSet* result_set, uint32 object_types, float range, bool cell_content) {
    ObjectList 	result_list;

    //see that we do not query more grids than necessary
    uint32_t CustomRange = range / (MAPWIDTH/GRIDWIDTH);

    if(CustomRange > VIEWRANGE) {
        CustomRange = VIEWRANGE;
    }

    if(CustomRange < 1)	{
        CustomRange = 1;
    }

    glm::vec3 position = object->getWorldPosition();
    getGrid()->GetCustomRangeCellContents(getGrid()->getCellId(position.x, position.z), CustomRange, &result_list, Bucket_Objects);

    std::for_each(result_list.begin(), result_list.end(), [object, position, result_set, object_types, range, cell_content] (Object* range_object) {
        if (range_object == object) {
            return;
        }

        ObjectType type = range_object->getType();

        if ((range_object->getType() & object_types) == static_cast<uint32_t>(type)) {
            if (glm::distance(object->getWorldPosition(), range_object->getWorldPosition()) <= range) {
                result_set->insert(range_object);
            }
        }

        // if its a building, add objects of our types it contains if wished
        if(type == ObjType_Building && cell_content) {
            ObjectList cells = static_cast<BuildingObject*>(range_object)->getAllCellChilds();

            std::for_each(cells.begin(), cells.end(), [=] (Object* cell) {
                ObjectType type = cell->getType();

                if ((type & object_types) == static_cast<uint32_t>(type)) {
                    TangibleObject* tangible = static_cast<TangibleObject*>(cell);

                    glm::vec3 tangible_position = tangible->getWorldPosition();

                    if (glm::distance(tangible_position, position) <= range) {
                        result_set->insert(tangible);
                    }
                }
            });
        }
    });
}

void SpatialIndexManager::viewCreaturesInRange(const Object* const object, std::function<void (Object* const creature)> callback)
{
	ObjectList result_list;
	
	getGrid()->GetViewingRangeCellContents(object->getGridBucket(), &result_list, (Bucket_Creatures&Bucket_Players));

    std::for_each(result_list.begin(), result_list.end(), [&] (Object* creature) {
		callback(creature);
	});
}

void SpatialIndexManager::viewObjectsInRange(const Object* const object, std::function<void (Object* const object)> callback)
{
	ObjectList result_list;
	
	getGrid()->GetViewingRangeCellContents(object->getGridBucket(), &result_list, Bucket_Objects);// (Bucket_Creatures&Bucket_Players));

    std::for_each(result_list.begin(), result_list.end(), [&] (Object* creature) {
		callback(creature);
	});
}


void SpatialIndexManager::viewPlayersInRange(const Object* const object, std::function<void (Object* const player)> callback)
{
	ObjectList result_list;
	
	getGrid()->GetViewingRangeCellContents(object->getGridBucket(), &result_list, (Bucket_Players));

    std::for_each(result_list.begin(), result_list.end(), [&] (Object* player) {
		callback(player);
	});
}

void SpatialIndexManager::viewAllInRange(const Object* const object, std::function<void (Object* const object)> callback)
{
	ObjectList result_list;
	
	getGrid()->GetViewingRangeCellContents(object->getGridBucket(), &result_list, (Bucket_Players&Bucket_Creatures&Bucket_Players));

    std::for_each(result_list.begin(), result_list.end(), [&] (Object* all) {
		callback(all);
	});
}

void SpatialIndexManager::getPlayersInRange(const Object* const object, PlayerObjectSet* result_set, bool cell_content) {
    //please note that players are always in the grid, even if in a cell!!!!
    ObjectList result_list;
    glm::vec3 position = object->getWorldPosition();

	getGrid()->GetPlayerViewingRangeCellContents(object->getGridBucket(), &result_list);

    std::for_each(result_list.begin(), result_list.end(), [object, result_set, cell_content] (Object* player) {
        if (object == player) {
            return;
        }

        if (!player->getParentId() || cell_content) {
            result_set->insert(static_cast<PlayerObject*>(player));
        }
    });
}


void SpatialIndexManager::sendToPlayersInRange(const Object* const object, bool cellContent, std::function<void (PlayerObject* player)> callback) {
    PlayerObjectSet		in_range_players;
    gSpatialIndexManager->getPlayersInRange(object, &in_range_players, cellContent);

    std::for_each(in_range_players.begin(), in_range_players.end(), [=] (PlayerObject* target) {
        if (target->isConnected()) {
            callback(target);
        }
    });
}



//============================================================================================================
// the idea is that the container holding our new item might be held by a container, too
// should this happen, we need to find the main container to determin what kind of creates to send to our player/s
// we will iterate through the parentObjects until the parent is either a player (item has been equipped) or in the inventory or )
// or a cell or a factory
uint64 SpatialIndexManager::getObjectMainParent(Object* object) {

    uint64 parentID = object->getParentId();

    // hack ourselves a player - it is not possible to get an inventory otherwise because
    // inventories are not part of the WorldObjectMap ... which really gets cumbersom (resolved with newest trunc)

    PlayerObject* player = dynamic_cast<PlayerObject*>(gWorldManager->getObjectById(parentID-1));
    if(!player)
    {
        // the backpack might have been equipped ?
        //   this way we have of course a player directly
        PlayerObject* player = dynamic_cast<PlayerObject*>(gWorldManager->getObjectById(parentID));
        if(!player)
        {
            CellObject* cell = dynamic_cast<CellObject*>(gWorldManager->getObjectById(parentID));
            if(!cell)
            {
                CellObject* cell = dynamic_cast<CellObject*>(object);
                if(cell)
                {
                    return parentID;
                }
                FactoryObject* factory = dynamic_cast<FactoryObject*>(gWorldManager->getObjectById(parentID));
                if(!factory)
                {
                    Object* ob = dynamic_cast<Object*>(gWorldManager->getObjectById(parentID));
                    if(!ob)
                    {
                        return 0;
                    }
                    parentID = getObjectMainParent(ob);
                }
            }
            else
            {
                //return the house
                return cell->getParentId();
            }
        }
    }
    else
    {
        //its in the inventory
        return parentID;
        //Inventory is parent ID +1 - we cannot find inventories in the worldObjectMap but we can find players there
        //so we have to go this way
        //before changing this we need to settle the dispute what objects are part of the world objectmap and need to discuss objectownership
        //Eru is right in saying that we cant have two object owners (well we can but obviously we shouldnt)
    }

    return parentID;
}

//====================================================================================================================
//
// send to all players in chatrange
void SpatialIndexManager::sendToChatRange(Object* container, std::function<void (PlayerObject* const player)> callback) {
    //get the Objects and unregister as necessary
    ObjectListType player_list;
    getGrid()->GetChatRangeCellContents(container->getGridBucket(), &player_list);

    std::for_each(player_list.begin(), player_list.end(), [callback] (Object* object) {
        callback(static_cast<PlayerObject*>(object));
    });
}

//=============================================================================================================================
//
// just create other players / creatures for us - we still exist for them as we were still in logged state
// player regsitrations are still intact at that point as we still are in the grid

void SpatialIndexManager::InitializeObject(PlayerObject *player) {
    //Pesudo
    // 1. Calculate CellID
    // 2. Set CellID
    // 3. Insert object into the cell in the hash table

    //now create around for us
    //we have to query the grid as noncontainers must be created to

    ObjectListType player_list;
    getGrid()->GetViewingRangeCellContents(player->getGridBucket(), &player_list, (Bucket_Creatures|Bucket_Objects|Bucket_Players));

    std::for_each(player_list.begin(), player_list.end(), [&] (Object* object) {
        if (object->getId() == player->getId()) {
            return;
        }

		sendCreateObject(object, player, false);

		if(object->getObjectType() == SWG_BUILDING)	{
			if(!object->checkRegisteredWatchers(player))	{
				return;
			}

			BuildingObject* building = dynamic_cast<BuildingObject*>(object);
			if( !building)	{
				DLOG(error) << "SpatialIndexManager::InitializeObject -> couldnt cast building " << object->getId();
				return;
			}

			building->ViewObjects(building, 0, false, [&] (Object* content_object) {
				if(content_object && content_object->getType() == ObjType_Tangible) {
					if(content_object->checkRegisteredWatchers(player))	{
						gSpatialIndexManager->sendCreateObject(content_object, player, false);
					}	
				}
			});

		}

        
    });

    //now building content in case we are in a building
    //initObjectsInRange(player);
    return;
}
