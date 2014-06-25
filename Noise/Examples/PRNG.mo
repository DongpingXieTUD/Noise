within Noise.Examples;
model PRNG "Shows the use of the basic PRNG block"
  import Noise;
   extends Modelica.Icons.Example;

  inner GlobalSeed globalSeed
    annotation (Placement(transformation(extent={{70,70},{90,90}})));
  Noise.PRNG prng
    annotation (Placement(transformation(extent={{-10,-12},{10,8}})));
equation

  annotation (experiment(
      StopTime=5,
      Interval=0.0005,
      __Dymola_fixedstepsize=0.001,
      __Dymola_Algorithm="Euler"),
    Documentation(revisions="<html>
<p><img src=\"modelica://Noise/Resources/Images/dlr_logo.png\"/> <b>Developed 2014 at the DLR Institute of System Dynamics and Control</b> </p>
</html>", info="<html>
<p>This example demonstrates, how the PRNG block can be instantiated. You can use this example to test different settings in the PRNG block.</p>
</html>"));
end PRNG;
