within Modelica_Noise.Math.Special;
function sinc "Unnormalized sinc function: sinc(u) = sin(u)/u"
  input Real u "Input argument";
  output Real y "= sinc(u) = sin(u)/u";
algorithm

  y := if abs(u) > 0.5e-4 then sin(u)/u else 1 - (u^2)/6 + (u^4)/120;

  annotation (Inline=true, Documentation(revisions="<html>
</html>", info="<html>
<h4>Syntax</h4>
<blockquote><pre>
Special.<b>sinc</b>(u);
</pre></blockquote>

<h4>Description</h4>
<p>
This function computes the unnormalized sinc function sinc(u) = sin(u)/u. The implementation utilizes
a Taylor series approximation for small values of u. Plot 
of the function:
</p>

<p><blockquote>
<img src=\"modelica://Modelica_Noise/Resources/Images/Math/Special/sinc.png\">
</blockquote></p>

<p>
For more details, see <a href=\"http://en.wikipedia.org/wiki/Sinc_function\">Wikipedia</a>.
</p>

<h4>Example</h4>
<blockquote><pre>
  sinc(0)   // = 1
  sinc(3)   // = 0.0470400026866224
</pre></blockquote>
</html>"));
end sinc;
