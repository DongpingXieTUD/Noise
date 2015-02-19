within Modelica_Noise.Blocks.Noise;
block SignalBasedNoise
  "Noise generator for Real numbers associated with the input signal (this block computes always the same (random) output y at the same value of the input signal)"
  import Modelica_Noise.Math.Random;
  import Modelica.Utilities.Streams.print;

  extends Modelica.Blocks.Interfaces.SO;

  // Main dialog menu
  parameter Boolean useTime = true
    "= true: u = time otherwise use input connector"
    annotation(choices(checkBox=true));

  parameter Real samplePeriod(start=0.01)
    "Period in signal for pseudo-sampling the raw random numbers"
    annotation(Dialog(enable=enableNoise));
  parameter Real y_min(start=0.0) "Minimum value of noise"
    annotation(Dialog(enable=enableNoise));
  parameter Real y_max(start=1.0) "Maximum value of noise"
    annotation(Dialog(enable=enableNoise));

  // Advanced dialog menu: Noise generation
  parameter Boolean enableNoise = true "=true: y = noise, otherwise y = y_off"
    annotation(choices(checkBox=true),Dialog(tab="Advanced",group="Noise generation"));
  parameter Real y_off = 0.0 "Output if enableNoise=false"
    annotation(Dialog(tab="Advanced",group="Noise generation"));
  //parameter Integer sampleFactor(min=1)=100
  //  "Events only at samplePeriod*sampleFactor if continuous"
  //  annotation(Evaluate=true,Dialog(tab="Advanced",group="Noise generation", enable=enableNoise));
  final parameter Integer shift = -interpolation.nPast
    "Shift noise samples to account for interpolation buffer"
    annotation(Dialog(tab="Advanced",group="Noise generation"));

  // Advanced dialog menu: Random number properties
  replaceable function distribution =
       Modelica_Noise.Math.TruncatedDistributions.Uniform.quantile constrainedby
    Modelica_Noise.Math.TruncatedDistributions.Interfaces.partialQuantile(
      final y_min=y_min, final y_max=y_max)
    "Random number distribution (truncated to y_min..y_max)"
    annotation(choicesAllMatching=true, Dialog(tab="Advanced",group="Random number properties",enable=enableNoise),
    Documentation(revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> Feb. 18, 2015 </td>
    <td valign=\"top\"> 

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica_Noise/Resources/Images/Blocks/Noise/dlr_logo.png\">
</td><td valign=\"bottom\"> 
         Initial version implemented by
         A. Kl�ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
  replaceable package interpolation =
      Modelica_Noise.Math.Random.Utilities.Interpolators.Linear constrainedby
    Modelica_Noise.Math.Random.Utilities.Interfaces.PartialInterpolator
    "Interpolation method in grid of raw random numbers"
    annotation(choicesAllMatching=true, Dialog(tab="Advanced",group="Random number properties",enable=enableNoise),
    Documentation(revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> Feb. 18, 2015 </td>
    <td valign=\"top\"> 

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica_Noise/Resources/Images/Blocks/Noise/dlr_logo.png\">
</td><td valign=\"bottom\"> 
         Initial version implemented by
         A. Kl�ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
  replaceable package generator =
      Modelica_Noise.Math.Random.Generators.Xorshift128plus constrainedby
    Modelica_Noise.Math.Random.Utilities.Interfaces.PartialGenerator
    "Random number generator"
    annotation(choicesAllMatching=true, Dialog(tab="Advanced",group="Random number properties",enable=enableNoise),
    Documentation(revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> Feb. 18, 2015 </td>
    <td valign=\"top\"> 

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica_Noise/Resources/Images/Blocks/Noise/dlr_logo.png\">
</td><td valign=\"bottom\"> 
         Initial version implemented by
         A. Kl�ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));

  // Advanced dialog menu: Initialization
  parameter Boolean useGlobalSeed = true
    "= true: use global seed, otherwise ignore it"
    annotation(choices(checkBox=true),Dialog(tab="Advanced",group = "Initialization",enable=enableNoise));
  parameter Boolean useAutomaticLocalSeed = true
    "= true: use instance name hash else fixedLocalSeed"
    annotation(choices(checkBox=true),Dialog(tab="Advanced",group = "Initialization",enable=enableNoise));
  parameter Integer fixedLocalSeed = 10
    "Local seed if useAutomaticLocalSeed = false"
      annotation(Dialog(tab="Advanced",group = "Initialization",enable=enableNoise and not useAutomaticLocalSeed));
  final parameter Integer localSeed = if useAutomaticLocalSeed then Modelica_Noise.Math.Random.Utilities.automaticLocalSeed(getInstanceName()) else
                                                                    fixedLocalSeed;
  parameter Real signalOffset = 0.0
    "Offset in signal for sampling the raw random numbers"
    annotation(Dialog(tab="Advanced", group="Initialization",enable=enableNoise));

  Modelica.Blocks.Interfaces.RealInput u if not useTime
    "Input signal (the noise depends on the value of u at the actual time instant"
    annotation (Placement(transformation(extent={{-140,-20},{-100,20}}, rotation=0)));

  // Retrieve values from outer global seed
protected
  outer Modelica_Noise.Blocks.Noise.GlobalSeed globalSeed
    "Definition of global seed via inner/outer";
  parameter Integer actualGlobalSeed = if useGlobalSeed then globalSeed.seed else 0
    "The global seed, which is atually used";
  parameter Boolean generateNoise = enableNoise and globalSeed.enableNoise
    "= true if noise shall be generated, otherwise no noise";

  // Construct sizes
  parameter Boolean continuous = interpolation.continuous
    "= true, if continuous interpolation";
  //parameter Real actualSamplePeriod = if continuous then sampleFactor*samplePeriod else samplePeriod
  //  "Sample period of when-clause";
  parameter Integer nFuture = interpolation.nFuture
    "Number of buffer elements to be predicted in the future (+1 for rounding errors)";
  parameter Integer nPast = interpolation.nPast
    "Number of buffer elements to be retained from the past";
  //parameter Integer nCopy = nPast + nFuture
  //  "Number of buffer entries to retain when re-filling buffer";
  parameter Integer nBuffer = nPast+1+nFuture "Size of buffer";
  //parameter Integer nBuffer = if continuous then nPast+sampleFactor+nFuture
  //                                          else nPast+      1     +nFuture
  //  "Size of buffer";

  // Declare buffers
  //discrete Integer state[generator.nState]
  //  "Internal state of random number generator";
  Real buffer[nBuffer] "Buffer to hold raw random numbers";
  //discrete Real bufferStartTime "The last time we have filled the buffer";
  Real r[nBuffer] "Uniform random number in the range (0,1]";

  Modelica.Blocks.Interfaces.RealInput signal
    "The input signal to the random number generator";
  Real offset = (signal-signalOffset) / samplePeriod;
equation
   if useTime then
     signal = time;
   else
     connect(signal,u);
   end if;

  // Continuously fill the buffer with random numbers
  for i in 1:nBuffer loop
    r[i]      = zeroDer(generator.random(
                        initialState(localSeed=localSeed,
                                     globalSeed=actualGlobalSeed,
                                     signal=(noEvent(integer(offset)) + i + shift) * samplePeriod + signalOffset)));
    buffer[i] = distribution(r[i]);
  end for;

  // Generate noise, if requested, and make it smooth, if it is
  y = if not generateNoise then y_off else
      if interpolation.continuous then
          smooth(interpolation.smoothness,
                 interpolation.interpolate(buffer=buffer,
                                           offset=offset - zeroDer(noEvent(integer(offset))) + nPast)) else
                 interpolation.interpolate(buffer=buffer,
                                           offset=offset - zeroDer(       (integer(offset))) + nPast);

  // We require a few smooth functions for derivatives
protected
  function convertRealToIntegers "Casts a double value to two integers"
  input Real real "The Real value";
  output Integer[2] int "The Integer values";

  external "C" ModelicaRandom_convertRealToIntegers(real,int);

  annotation (Include = "#include \"ModelicaRandom.c\"", Documentation(revisions="<html>
<p><img src=\"modelica://Noise/Resources/Images/dlr_logo.png\"/> <b>Developed 2014 at the DLR Institute of System Dynamics and Control</b> </p>
</html>", info="<html>
<h4>Syntax</h4>
<blockquote><pre>
int = <b>convertRealToInteger</b>(real);
</pre></blockquote>
<h4>Description</h4>
<p>
The Real input argument real is mapped to two Integer values int[1] and int[2].
The function assumes that two Integer values have exactly the same length
as one Real value (e.g. one Integer has a lenght of 32 bits and one Real
value has a lenght of 64 bits).
</p>
</html>"));
  end convertRealToIntegers;

  function initialState "Combine Real signal with Integer seeds"
    input Integer localSeed "The local seed";
    input Integer globalSeed "the global seed";
    input Real signal "The Real signal";
    output Integer state[generator.nState]
      "The initial state of random number generator";
  protected
    Integer ints[2] "Real signal casted to integers";
  algorithm
    ints  := convertRealToIntegers(signal);
    state := generator.initialState(localSeed+ints[1], globalSeed+ints[2]);
  end initialState;

  function zeroDer "Declare an expression to have zero derivative"
    input Real u "Original expression";
    input Real dummy = 0 "Dummy variable to have something to derive (=0)";
    output Real y "=u";
  algorithm
    y := u;
    annotation(Inline=false,derivative(noDerivative = u) = der_zeroDer);
  end zeroDer;

  function der_zeroDer "Zero derivative for zeroDer(expression)"
    input Real u "Original expression";
    input Real dummy = 0 "Dummy variable to have somthing to derive (=0)";
    input Real der_dummy = 0 "der(dummy)";
    output Real der_y "der(y) = der(u) = 0";
  algorithm
    der_y := 0;
    annotation(Inline=true);
  end der_zeroDer;

    annotation(Dialog(tab="Advanced",group = "Initialization",enable=enableNoise),
              Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics={
        Polygon(
          points={{-76,90},{-84,68},{-68,68},{-76,90}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(points={{-76,68},{-76,-80}}, color={192,192,192}),
        Line(points={{-86,0},{72,0}}, color={192,192,192}),
        Polygon(
          points={{94,0},{72,8},{72,-8},{94,0}},
          lineColor={192,192,192},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid),
        Line(visible=  enableNoise,
           points={{-75,-13},{-61,-13},{-61,3},{-53,3},{-53,-45},{-45,-45},{-45,
              -23},{-37,-23},{-37,61},{-29,61},{-29,29},{-29,29},{-29,-31},{-19,
              -31},{-19,-13},{-9,-13},{-9,-41},{1,-41},{1,41},{7,41},{7,55},{13,
              55},{13,-1},{23,-1},{23,11},{29,11},{29,-19},{39,-19},{39,53},{49,
              53},{49,19},{57,19},{57,-47},{67,-47}},
            color={0,0,0}),
        Text(visible=enableNoise,
          extent={{-150,-110},{150,-150}},
          lineColor={0,0,0},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid,
          textString=if useTime then "%samplePeriod s" else "%samplePeriod"),
        Line(visible=not enableNoise,
          points={{-76,56},{72,56}},
          color={0,0,0},
          smooth=Smooth.None),
        Text(visible=not enableNoise,
          extent={{-75,50},{95,10}},
          lineColor={0,0,0},
          fillColor={192,192,192},
          fillPattern=FillPattern.Solid,
          textString="%y_off")}),
    Documentation(info="<html>
<p>A summary of the properties of the noise blocks is provided in the documentation of package <a href=\"modelica://Modelica_Noise.Blocks.Noise\">Blocks.Noise</a>. This SignalBasedNoise block generates reproducible noise at its output. The block can only be used if on the same or a higher hierarchical level, model <a href=\"modelica://Modelica_Noise.Blocks.Noise.GlobalSeed\">Blocks.Noise.GlobalSeed</a> is dragged to provide global settings for all instances. </p>
<p>The generated random numbers of this block are a function of the input signal. Blocks with different input signals produce uncorrelated noise. This can be used to define e.g. the roughness of a railway track. The random values provided at the output of a SignalBasedNoise instance depend (a) on the <b>actual input signal</b> in the current time instant, (b) on the instance name, and (c) on the settings of the respective instance (as well as the seetings in globalSeed, see above and below). By default, two or more instances produce different, uncorrelated noise for the same input signal. </p>
<p><b>Parameters that need to be defined</b> </p>
<p>When using this block, at a minimum the following parameters must be defined: </p>
<table cellspacing=\"0\" cellpadding=\"2\" border=\"1\"><tr>
<td><p align=\"center\"><h4>Parameter</h4></p></td>
<td><p align=\"center\"><h4>Description</h4></p></td>
</tr>
<tr>
<td><p>useTime </p></td>
<td><p>If useTime=true, then the input signal is replaced by the current simulation time. This is the default. If useTime=false, then an input connector is used, which defines the ordinate of the random signal. For each value of the input signal, a different random number is generated.</p></td>
</tr>
<tr>
<td><p>samplePeriod </p></td>
<td><p>Random values are drawn on a periodic grid over the input signal. The period of this grid is defined with this parameter. The unit of the samplePeriod corresponds to the unit of the input signal. If useTime=true, then the samplePeriod defines a sample Period in [s]. As a result of this pseudo-sampling, the highest frequency f<sub>max</sub> contained in the generated noise is f<sub>max</sub> = 1/samplePeriod. By default, no events are generated. In between, the noise is linearly interpolated at the drawn random values.</p></td>
</tr>
<tr>
<td><p>y_min, y_max</p></td>
<td><p>Upper and lower bounds for the noise. With the default setting, uniform noise is generated within these bounds.</p></td>
</tr>
</table>
<p><br><br><br><br>As a simple demonstration, see example <a href=\"Blocks.Examples.NoiseExamples.SignalBasedNoise\">Blocks.Examples.NoiseExamples.SignalBasedNoise</a>. In the next diagram, a simulation result is shown with a ramped input signal repeated every second. The generated random numbers then also repeat every second!</p>
<blockquote><img src=\"modelica://Modelica_Noise/Resources/Images/Blocks/Examples/NoiseExamples/SignalBasedNoise.png\"/> </blockquote>
<h4>Advanced tab: General settings</h4>
<p>In the <b>Advanced</b> tab of the parameter menu, further options can be set. The general settings are shown in the next table: </p>
<table cellspacing=\"0\" cellpadding=\"2\" border=\"1\"><tr>
<td><p align=\"center\"><h4>Parameter</h4></p></td>
<td><p align=\"center\"><h4>Description</h4></p></td>
</tr>
<tr>
<td><p>enableNoise </p></td>
<td><p>= true, if noise is generated at the output of the block.</p><p>= false, if noise generation is switched off and the constant value y_off is provided as output.</p></td>
</tr>
<tr>
<td><p>y_off </p></td>
<td><p>If enableNoise = false, the output of the block instance has the value y_off. Default is y_off = 0.0. Furthermore, if time&LT;startTime, the output of the block is also y_off.</p></td>
</tr>
</table>
<p><br><br><br><br><br><b>Advanced tab: Random number properties</b></p>
<p>In the group &QUOT;Random number properties&QUOT;, the properties of the random number generation are defined. By default, uniform random numbers with linear interpolation are used, and the random numbers are drawn with the pseudo random number generator algorithm &QUOT;xorshift128+&QUOT;. This random number generator has a period of 2^128, has an internal state of 4 Integer elements, and has excellent statistical properties. If the default behavior is not desired, the following parameters can be set: </p>
<table cellspacing=\"0\" cellpadding=\"2\" border=\"1\"><tr>
<td><p align=\"center\"><h4>Parameter</h4></p></td>
<td><p align=\"center\"><h4>Description</h4></p></td>
</tr>
<tr>
<td><p>distribution </p></td>
<td><p>Defines the random number distribution to map random numbers from the range 0.0 ... 1.0, to the desired range and distribution. Basically, <b>distribution</b> is a replaceable function that provides the truncated quantile (= truncated inverse cumulative distribution function) of a random distribution. More details of truncated distributions can be found in the documentation of package <a href=\"modelica://Modelica_Noise.Math.TruncatedDistributions\">Math.TruncatedDistributions</a>. </p></td>
</tr>
<tr>
<td><p>interpolation </p></td>
<td><p>Defines the type of interpolation between the random values drawn at sample instants. This is a replaceable package. The following interpolation packages are provided in package <a href=\"modelica://Modelica_Noise.Math.Random.Utilities.Interpolators\">Math.Random.Utilities.Interpolators</a>: </p><ul>
<li>Constant: The random values are held constant between sample instants. </li><li>Linear: The random values are linearly interpolated between sample instants. </li><li>SmoothIdealLowPass: The random values are smoothly interpolated with the <a href=\"modelica://Modelica_Noise.Math.Special.sinc\">sinc</a> function. This is an approximation of an ideal low pass filter (that would have an infinite steep drop of the frequency response at the cut-off frequency 1/samplePeriod). </li>
</ul></td>
</tr>
<tr>
<td><p>generator </p></td>
<td><p>Defines the pseudo random number generator to be used. This is a replaceable package. The random number generators that are provided in package <a href=\"modelica://Modelica_Noise.Math.Random.Generators\">Math.Random.Generators</a> can be used here. Properties of the various generators are described in the package description of the Generators package.</p></td>
</tr>
</table>
<p><br><br><br><br><br>The different interpolation methods are demonstrated with example <a href=\"modelica://Modelica_Noise.Blocks.Examples.NoiseExamples.Interpolation\">Examples.NoiseExamples.Interpolation</a>. The example uses the block <a href=\"TimeBasedNoise\">TimeBasedNoise</a>, but the results also hold for SignalBasedNoise. A simulation result is shown in the next diagram: </p>
<blockquote><img src=\"modelica://Modelica_Noise/Resources/Images/Blocks/Examples/NoiseExamples/Interpolation1.png\"/> </blockquote>
<p>As can be seen, constant (constantNoise.y) and linear (linearNoise.y) interpolation respect the defined band -1 .. 3. Instead, smooth interpolation with the sinc function (smoothNoise.y) may violate the band slightly in order to be able to smoothly interpolate the random values at the sample instants. In practical applications, this is not an issue because the exact band of the noise is usually not exactly known. </p>
<p>The selected interpolation method does not change the mean value of the noise signal, but it changes its variance with the following factors: </p>
<table cellspacing=\"0\" cellpadding=\"2\" border=\"1\"><tr>
<td><p align=\"center\"><h4>interpolation</h4></p></td>
<td><p align=\"center\"><h4>variance factor</h4></p></td>
</tr>
<tr>
<td><p>Constant </p></td>
<td><p>1.0</p></td>
</tr>
<tr>
<td><p>Linear </p></td>
<td><p>2/3 (actual variance = 2/3*&LT;variance of constantly interpolated noise&GT;)</p></td>
</tr>
<tr>
<td><p>SmoothIdealLowPass </p></td>
<td><p>0.979776342307764 (actual variance = 0.97..*&LT;variance of constantly interpolated noise&GT;)</p></td>
</tr>
</table>
<p><br><br><br>The above table holds only if an event is generated at every sample instant, or for very small relative tolerances. Otherwise, the variance depends also slightly on the step-size and the interpolation method of the integrator. Therefore, if the variance of the noise is important for your application, either change the distribution definition to take the factors above into account, or use only constant interpolation. </p>
<p><b>Advanced tab: Initialization</b> </p>
<p>The random number generators must be properly initialized, especially that different instances of the noise block generate uncorrelated noise. For this purpose the following parameters can be defined. </p>
<table cellspacing=\"0\" cellpadding=\"2\" border=\"1\"><tr>
<td><p align=\"center\"><h4>Parameter</h4></p></td>
<td><p align=\"center\"><h4>Description</h4></p></td>
</tr>
<tr>
<td><p>useGlobalSeed </p></td>
<td><p>= true, if the seed (= Integer number) defined in the &QUOT;inner GlobalSeed globalSeed&QUOT; component is used for the initialization of the random number generators. Therefore, whenever the globalSeed defines a different number, the noise at every instance is changing.</p><p>= false, if the seed defined by globalSeed is ignored. For example, if aerodynamic turbulence is modelled with a noise block and this turbulence model shall be used for all simulation runs of a Monte Carlo simulation, then useGlobalSeed has to be set to false.</p></td>
</tr>
<tr>
<td><p>useAutomaticLocalSeed </p></td>
<td><p>An Integer number, called local seed, is needed to generate different random signals with every block instance. Instances using the same local seed produce exactly the same random number values (so the same noise, if the other settings of the instances are the same). If useAutomaticLocalSeed = true, the local seed is determined automatically as hash value of the instance name of the noise block. If useAutomaticLocalSeed = false, the local seed is defined explicitely by parameter fixedLocalSeed. This might be useful, if you use the noise block to model the roughness of a road and the road should be the same for every vehicle.</p></td>
</tr>
<tr>
<td><p>fixedLocalSeed </p></td>
<td><p>If useAutomaticLocalSeed = false, the local seed to be used. fixedLocalSeed can be any Integer number (including zero or a negative number). The initialization algorithm produces a meaningful initial state of the random number generator, so subsequently drawing random numbers produces statistically meaningful numbers.</p></td>
</tr>
<tr>
<td><p>signalOffset </p></td>
<td><p>The signalOffset parameter can be used to shift the input signal. This can be used, if you wish the pseudo-sampling (see parameter samplePeriod) to happen at specific values of the input signal.</p></td>
</tr>
</table>
</html>", revisions="<html>
<p>
<table border=1 cellspacing=0 cellpadding=2>
<tr><th>Date</th> <th align=\"left\">Description</th></tr>

<tr><td valign=\"top\"> Feb. 18, 2015 </td>
    <td valign=\"top\"> 

<table border=0>
<tr><td valign=\"top\">
         <img src=\"modelica://Modelica_Noise/Resources/Images/Blocks/Noise/dlr_logo.png\">
</td><td valign=\"bottom\"> 
         Initial version implemented by
         A. Kl�ckner, F. v.d. Linden, D. Zimmer, M. Otter.<br>
         <a href=\"http://www.dlr.de/rmc/sr/en\">DLR Institute of System Dynamics and Control</a>
</td></tr></table>
</td></tr>

</table>
</p>
</html>"));
end SignalBasedNoise;