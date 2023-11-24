void MapInit()
{
    CYCLERMODEL::EntityRegister();

    // Triggers
    //TRIGGERGRAVITY::EntityRegister();
    //TRIGGERSPEED::EntityRegister();

    // Button
    //BUTTONGAUGE::EntityRegister();

    // Misc
    //MOUNTGUN::EntityRegister();
}

namespace CYCLERMODEL
{

enum CyclerState
{
    CYCLER_START = 0,
    CYCLER_CHANGE,
    CYCLER_END
};

class cyclermdl : ScriptBaseAnimating
{
    // Config
    private string m_szModel1, m_szModel2;
    private int m_iSeq1, m_iSeq2;
    private float m_flFrameRate;
    private Vector m_Controller;

    bool KeyValue(const string& in szKey, const string& in szValue)
    {
        if( szKey == "_mdl0" )
            m_szModel1 = szValue;
        else if( szKey == "_mdl1")
            m_szModel2 = szValue;
        else if( szKey == "_seq0" )
            m_iSeq1 = atoi( szValue );
        else if( szKey == "_seq1" )
            m_iSeq2 = atoi( szValue );
        else if( szKey == "controller" )
            g_Utility.StringToVector( m_Controller, szValue );
        else
            return BaseClass.KeyValue( szKey, szValue );

        return true;
    }

    // Precache the models
    void Precache()
    {
        // Models
        if(!string(self.pev.model).IsEmpty())
            g_Game.PrecacheModel( self.pev.model );

        if(!string(m_szModel1).IsEmpty() && string(m_szModel1) != string(self.pev.model))
           g_Game.PrecacheModel( m_szModel1 ); 

        if(!string(m_szModel2).IsEmpty() && string(m_szModel2) != string(self.pev.model))
           g_Game.PrecacheModel( m_szModel2 ); 

        BaseClass.Precache();
    }

    // Spawn the entity
    void Spawn( )
    {
        self.Precache();
        
        // Model
        g_EntityFuncs.SetModel( self, self.pev.model );

        // Physics
        self.pev.solid      = SOLID_SLIDEBOX;
        self.pev.movetype   = MOVETYPE_NONE;

        // No damage
        self.pev.takedamage	= DAMAGE_NO;

        // Size & origin
        g_EntityFuncs.SetOrigin( self, self.pev.origin );
        g_EntityFuncs.SetSize( self.pev, Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) );

        // Controller
        self.pev.set_controller( 0, int(m_Controller.0) );
        self.pev.set_controller( 1, int(m_Controller.1) );
        self.pev.set_controller( 2, int(m_Controller.2) );
        self.pev.set_controller( 3, int(m_Controller.3) );

        // Current state
        self.pev.iuser1 = CYCLER_START;

        // Save data
        m_flFrameRate = self.pev.framerate;
        
        // Spawn
        BaseClass.Spawn();
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
    {
        // Filter by entity called state
        switch( self.pev.iuser1 )
        {
            case MDL_1:
            {
                UpdateModel( self, m_szModelState, Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) );
                SetSequence( self, m_iSeq1, m_flFrameRate );

                // Next State
                self.pev.iuser1 = MDL_2;
                break;
            }
            case MDL_2:
            {   
                UpdateModel( self, m_szModelEnd, Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) );
                SetSequence( self, m_iSeq2, m_flFrameRate );

                // Next State
                self.pev.iuser1 = MDL_1;
                break;
            }
        }
    }
}

// Register
bool EntityRegister()
{
    g_CustomEntityFuncs.RegisterCustomEntity( "CYCLERMODEL::cyclermdl", "cycler_mdl" );
    return g_CustomEntityFuncs.IsCustomEntity( "cycler_mdl" );
}

} // End

// Stocks
void UpdateModel(CBaseEntity@ entity, const string& in szModel, const Vector& in vMins, const Vector& in vMaxs)
{
    g_EntityFuncs.SetModel( entity, szModel );
    g_EntityFuncs.SetOrigin( entity, entity.pev.origin );
    g_EntityFuncs.SetSize( entity.pev, vMins, vMaxs );
}

void SetSequence(CBaseEntity@ entity, const int& in iSequence, const float& in flFrameRate = 1.0)
{
    entity.pev.animtime = g_Engine.time;
    entity.pev.framerate = flFrameRate;
    entity.pev.sequence = iSequence;
}
