with Generic_Sensor;

with Units; use Units;
with HMC5883L.Driver;
with Units.Navigation; use Units.Navigation;
with Units.Vectors; use Units.Vectors;
with Interfaces; use Interfaces;

package Magnetometer with SPARK_Mode is

   type Magnetometer_Data_Type is record
      heading : Heading_Type;
      magnetic_vector : Magnetic_Flux_Density_Vector;
      orientation : Orientation_Type;
   end record;

   package Magnetometer_Sensor is new Generic_Sensor(Magnetometer_Data_Type); use Magnetometer_Sensor;

   type Magnetometer_Tag is new Magnetometer_Sensor.Sensor_Tag with record
      null;
   end record;

   overriding procedure initialize (Self : in out Magnetometer_Tag);
   -- with Global => (In_Out => (HMC5883L.Driver.State));

   overriding procedure read_Measurement(Self : in out Magnetometer_Tag);
   -- with Global => (In_Out => (HMC5883L.Driver.State, HMC5883L.Driver.Coefficients));


   procedure compensateOrientation(Self : Magnetometer_Tag; orientation : Orientation_Type);
   function get_Heading(Self : Magnetometer_Tag) return Heading_Type;

   Sensor : Magnetometer_Tag;

private
   function Heading(mag_vector : Magnetic_Flux_Density_Vector; orientation : Orientation_Type) return Heading_Type;

end Magnetometer;