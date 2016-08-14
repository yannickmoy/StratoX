-- Generic Kalman Filter Package
-- Author: Emanuel Regnath (emanuel.regnath@tum.de)

with Ada.Real_Time;

with Units; use Units;
with Units.Vectors; use Units.Vectors;
with Units.Navigation; use Units.Navigation;

package Kalman with 
SPARK_Mode, 
Abstract_State => State
is

   -- the states: everything that needs to be estimated for a solution
   
   type State_Vector_Index_Name_Type is 
   ( X_LON,
     X_LAT,
     X_ALT,
     X_GROUND_SPEED_X,   -- NORTH => + lat
     X_GROUND_SPEED_Y,   -- EAST => + lon
     X_GROUND_SPEED_Z,   -- DOWN => - alt
     X_ROLL,
     X_PITCH,
     X_YAW,
     X_ROLL_RATE,
     X_PITCH_RATE,
     X_YAW_RATE,
     X_ROLL_BIAS,
     X_PITCH_BIAS,
     X_YAW_BIAS,
     X_AIR_SPEED_X,
     X_AIR_SPEED_Y,
     X_AIR_SPEED_Z
    );
    
   subtype State_Vector_Index_Type is Natural range 1 .. State_Vector_Index_Name_Type'Range_Length;
   
   type State_Vector is record -- 16 states
      pos : GPS_Loacation_Type;
      ground_speed : Linear_Velocity_Vector;  
      orientation : Orientation_Type;
      rates : Angular_Velocity_Vector;
      bias : Angular_Velocity_Vector;
      air_speed : Linear_Velocity_Vector;
   end record;


   -- the inputs: everything that you can control
   type Input_Vector_Index_Name_Type is 
   ( U_ELEVATOR,
     U_AILERON,
     U_RUDDER );

   subtype Input_Vector_Index_Type is Natural range 1 .. Input_Vector_Index_Name_Type'Range_Length;


   type Input_Vector is record
      Elevator : Angle_Type;
      Aileron  : Angle_Type;
      Rudder   : Angle_Type;
   end record;

   -- the observations: everything that can be observed
   type Observation_Vector_Index_Name_Type is
   ( Z_LON,
     Z_LAT,
     Z_ALT,
     Z_BARO_ALT,
     Z_ROLL,
     Z_PITCH,
     Z_YAW,
     Z_ROLL_RATE,
     Z_PITCH_RATE,
     Z_YAW_RATE
    );
    
   subtype Observation_Vector_Index_Type is Natural range 1 .. Observation_Vector_Index_Name_Type'Range_Length;   
   
   type Observation_Vector is record
      gps_pos : GPS_Loacation_Type;
      baro_alt : Altitude_Type;
      acc_ori : Orientation_Type;
      gyr_rates : Angular_Velocity_Vector;
      --mag_ori : Magnetic_Flux_Density_Vector; 
   end record; 


   --  Kalman Equations
   --  1. predict
   --  x = Ax + Bu
   --  P = APA' + Q
   --
   --  2. update
   --  y = z - Hx
   --  S = HPH' + R
   --  K = PH' / S
   --  x = x + Ky'
   --  P = (1 - KH)P

   -- Sensor Fusion: 
   -- 1. Each time a new measurement becomes available a new estimate will be computed z_i, H_i
   -- 2. observation matrix with M lines for M sensors
   -- 3. Calculate Mean


   function map( index : State_Vector_Index_Name_Type ) return State_Vector_Index_Type is
   ( State_Vector_Index_Type( State_Vector_Index_Name_Type'Pos( index ) + 1 ) );

   function map( index : Input_Vector_Index_Name_Type ) return Input_Vector_Index_Type is
   ( Input_Vector_Index_Type( Input_Vector_Index_Name_Type'Pos( index ) + 1 ) );

   function map( index : Observation_Vector_Index_Name_Type ) return Observation_Vector_Index_Type is
   ( Observation_Vector_Index_Type( Observation_Vector_Index_Name_Type'Pos( index ) + 1 ) );



   -- k states, l inputs, m observations 
   --type kk_Matrix is array( 1 .. k, 1 .. k ) of Float;
   subtype kk_Matrix is Unit_Matrix( State_Vector_Index_Type, State_Vector_Index_Type);
   subtype kl_Matrix is Unit_Matrix( State_Vector_Index_Type, Input_Vector_Index_Type);
   subtype mk_Matrix is Unit_Matrix( Observation_Vector_Index_Type, State_Vector_Index_Type);
   subtype km_Matrix is Unit_Matrix( State_Vector_Index_Type, Observation_Vector_Index_Type);   
   subtype mm_Matrix is Unit_Matrix( Observation_Vector_Index_Type, Observation_Vector_Index_Type);


   subtype State_Transition_Matrix is kk_Matrix;

   subtype Input_Transition_Matrix is kl_Matrix;

   subtype Observation_Transition_Matrix is mk_Matrix;

   subtype State_Covariance_Matrix is kk_Matrix;
--     is record 
--        orientation : Unit_Matrix3D;
--        rates : Unit_Matrix3D;
--     end record;



   type Innovation_Vector is record
      delta_gps_pos : GPS_Translation_Type;
      delta_baro_alt : Altitude_Type;
      delta_acc_ori : Rotation_Vector;
      delta_gyr_rates : Angular_Velocity_Vector;   
   end record;
   
   subtype Innovation_Covariance_Matrix is mm_Matrix;
   
   subtype Kalman_Gain_Matrix is km_Matrix;

   subtype State_Noise_Covariance_Matrix is kk_Matrix;
   subtype Observation_Noise_Covariance_Matrix is mm_Matrix;

   


   procedure reset;

   procedure perform_Filter_Step( u : in Input_Vector; z : in Observation_Vector );

   -- 1. step
   procedure predict( u : in Input_Vector; dt : Time_Type);

   -- 2. step
   procedure update( z : in Observation_Vector; dt : Time_Type );
   
   
   function get_States return State_Vector;


private

   -- Prediction
   procedure predict_state( state : in out State_Vector; input : Input_Vector; dt : Time_Type );
   procedure predict_cov( P : in out State_Covariance_Matrix; Q : State_Noise_Covariance_Matrix );
   
   
   -- Update
   procedure uptate_state( states : in out State_Vector; samples : Observation_Vector; dt : Time_Type );
   procedure update_cov( P : in out State_Covariance_Matrix; dt : Time_Type );



   function "-"(Left, Right : Observation_Vector) return Innovation_Vector;

   procedure calculate_A( A : out State_Transition_Matrix; dt : Time_Type );

   -- input2state, state,  A, Au PHP
--     function State_Prediction( u : Input_Vector; dt : Time_Type ) return State_Vector;
--     function State_Prediction( x : State_Vector; dt : Time_Type ) return State_Vector;
--     function Observation_Prediction( x : State_Vector; dt : Time_Type ) return Observation_Vector;
--     
--     
--     function Cov_Prediction( P : State_Covariance_Matrix; dt : Time_Type);
--     function Cov_Innovation( P : State_Covariance_Matrix; dt : Time_Type);
--     


   
   -- Matrix calculations
--     function "*"( A : State_Transition_Matrix; x : State_Vector ) return State_Vector;
--     function "*"( B : Input_Transition_Matrix; u : Input_Vector ) return State_Vector;
--     function "+"( Left : State_Vector; Right : State_Vector) return State_Vector;
--  
--     function "*"( Left : State_Transition_Matrix; Right : State_Covariance_Matrix) return State_Covariance_Matrix;
--  
--     function "*"( Left : Observation_Transition_Matrix; Right : State_Vector) return Observation_Vector;
--     function "-"( Left : Observation_Vector; Right : Observation_Vector) return Observation_Vector;


end Kalman;
