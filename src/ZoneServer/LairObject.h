/*
---------------------------------------------------------------------------------------
This source file is part of SWG:ANH (Star Wars Galaxies - A New Hope - Server Emulator)

For more information, visit http://www.swganh.com

Copyright (c) 2006 - 2010 The SWG:ANH Team
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

#ifndef ANH_ZONESERVER_LAIR_OBJECT_H
#define ANH_ZONESERVER_LAIR_OBJECT_H

#include "AttackableStaticNpc.h"
#include "MathLib/Rectangle.h"

//=============================================================================

/*
- creature lair
*/

#include <vector>

#define MaxWaveSize 6
// The kinds of creature (or NPC) a lair can call: an NPC camp has up to 7
// (the Jawa warband); 5 crashed the zone at load (docs/SPAWNS.md).
#define MaxCreatureTypes 8


typedef enum _Lair_State
{
    State_LairIdle = 0,
    State_LairDead = 1,
    State_LairUnspawned = 2,
    State_LairAlerted = 3,
    State_LairCombatReady = 4,
    State_LairCombat = 5
} Lair_State;

class LairObject :	public AttackableStaticNpc//, ObjectFactoryCallback
{
    friend class NonPersistentNpcFactory;

public:
    LairObject(uint64 templateId);
    virtual ~LairObject();

    // The target of a destroy mission: spawns where it was put, at once,
    // reports its destruction to the mission, and does not respawn.
    void	setMission(uint64 missionId, uint64 ownerId) {
        mMissionId = missionId;
        mMissionOwnerId = ownerId;
    }
    bool	isMissionLair(void) const {
        return mMissionId != 0;
    }

    // A camp (docs/SPAWNS.md, NPC camps): an invisible lair is not shown
    // to players (lair_invisible; pre-CU "invisible lairs", spawn points
    // with nothing to destroy) but calls its creatures as any lair; a lair
    // with lair_building puts the client's camp building at its spot.
    bool	isInvisible(void);

    // Attacked: its creatures that are alive and not fighting come for the
    // attacker.
    void	defend(uint64 attackerId) const;

    virtual void prepareCustomRadialMenu(CreatureObject* creatureObject, uint8 itemCount);

    virtual void	addKnownObject(Object* object);

    virtual void	handleEvents(void);
    virtual uint64	handleState(uint64 timeOverdue);
    virtual void	inPeace(void);

    virtual void	killEvent(void);
    virtual void	respawn(void);

    void	spawn(void);
    void	reportedDead(uint64 deadCreatureId);
    // A creature of this lair has just died (its corpse stays a few
    // minutes; reportedDead comes when it goes). A lair in waves counts it
    // now, so the next wave follows the last kill, not the last corpse.
    void	creatureDied(uint64 creatureId) { if (!mStageEnd.empty()) { reportedDead(creatureId); } }
    bool	requestAssistance(uint64 targetId, uint64 sourceId) const;
    void	requestLairAssistance(void) const;

    void	setSpawnArea(const Anh_Math::Rectangle &mSpawnArea);
    void	setCreatureTemplate(uint32 index, uint64 creatureTemplateId);
    void	setCreatureSpawnRate(uint32 index, uint32 spawnRate);
    virtual float getMaxSpawnDistance(void) {
        return mMaxSpawnDistance;
    }

    uint64	mCreatureId[MaxWaveSize];
    int32	mPassiveCreature[MaxWaveSize];

private:
    LairObject();

    bool	playerInRange(float range);
    void	spawnInitialWave(void);

    // Waves (lair_wave_stages, e.g. "3,3,2"): the lair's kinds of creature,
    // in their group's order, split into stages. Each wave calls a full
    // wave of the current stage's kinds; when all of it is dead the next
    // stage follows after lair_wave_delay, and after the last the lair
    // starts again from the first after its respawn delay. With
    // lair_wave_boss, the last stage's last kind is its leader: one in the
    // wave, the rest of the wave the stage's other kinds.
    bool	isStaged(void) const { return !mStageEnd.empty(); }
    uint64	pickCreatureTemplate(int32 slot) const;
    void	spawnStageWave(void);
    std::vector<int32>	mStageEnd;		// each stage's end, an index into the kinds
    int32	mStage = 0;
    int32	mStageAlive = 0;
    bool	mWaveBoss = false;
    uint64	mWaveDelay = 30000;			// ms between a stage's end and the next
    uint64	mNextWaveAt = 0;			// local time of the next wave, 0 for none
    bool	getLairTarget(void);
    void	makePeaceWithDefendersOutOfRange(void);

    Anh_Math::Rectangle mSpawnArea;

    Lair_State	mLairState;

    int32	mCreatureSpawnRate[MaxCreatureTypes];

    int64	mInitialSpawnDelay;			// in ms
    uint64	mCreatureTemplates[MaxCreatureTypes]; // Creature templates and spwan rate to be used by lair.
    uint64	mLairsTypeId;
    uint64 mSpawnCell;
    // This is the max stalking distance from the spawn point or other central point, like lair.
    // Will be used when calculating spawn positions within a region. We do not allow the creatures to move outside the region.
    float	mMaxStalkerDistance;	// Raduis from lair.
    float	mMaxSpawnDistance;		// Max distance from lair where creature should spawn.
    int32	mActiveWaves;
    int32	mCreatureBabySpawnRate;		// Not uses yet.
    int32	mPassiveWaves;
    int32	mWaveSize;
    bool	mInitialized;
    uint64	mMissionId;
    uint64	mMissionOwnerId;
    uint64	mCampBuildingId;	// the camp building it put up, 0 for none
    bool	mSpawned;
    bool	mSpawnPositionFixed;
};

//=============================================================================

#endif
