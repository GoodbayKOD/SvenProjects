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
    private int m_iSequenceStart, m_iSequenceState, m_iSequenceEnd;
    private float m_flFrameRate;
    private Vector m_Controller;

    bool KeyValue(const string& in szKey, const string& in szValue)
    {
        if( szKey == "_mdl0" )
            m_szModel1 = szValue;
        else if( szKey == "_mdl1")
            m_szModel2 = szValue;
        else if( szKey == "_seq1" )
            m_iSequenceState = atoi( szValue );
        else if( szKey == "_seq0" )
            m_iSequenceEnd = atoi( szValue );
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
        g_Game.PrecacheModel( self.pev.model );
        g_Game.PrecacheModel( m_szModel2 );
        g_Game.PrecacheModel( m_szModel3 );

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
        self.pev.set_controller( 0, int(m_Controller.y) );
        self.pev.set_controller( 1, int(m_Controller.x) );
        self.pev.set_controller( 2, int(m_Controller.z) );

        // Current state
        self.pev.iuser1 = CYCLER_START;

        // Save data
        m_szModelStart      = self.pev.model;
        m_iSequenceStart    = self.pev.sequence;
        m_flFrameRate       = self.pev.framerate;
        
        BaseClass.Spawn();
    }

    void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
    {
        // Filter by entity called state
        switch( self.pev.iuser1 )
        {
            case CYCLER_START:
            {
                UpdateModel( self, m_szModelState, Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) );
                SetSequence( self, m_iSequenceState );

                // Next State
                self.pev.iuser1 = CYCLER_CHANGE;
                break;
            }
            case CYCLER_CHANGE:
            {   
                UpdateModel( self, m_szModelEnd, Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) );
                SetSequence( self, m_iSequenceEnd );

                // Next State
                self.pev.iuser1 = CYCLER_END;
                break;
            }
            case CYCLER_END:
            {
                UpdateModel( self, m_szModelStart, Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) );
                SetSequence( self, m_iSequenceStart );

                // Next State
                self.pev.iuser1 = CYCLER_START;
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
