double abs(double x)
{
  return (x < 0) ? -x : x;
}

public enum errorMethod
{
  absolute, square
}

abstract class Simulator 
{
  //final double PIDtimeStep = 0.001;
  double setpoint = 100;
  double errorIntegral = 0;
  errorMethod method = errorMethod.absolute;

  public double fitness = 0;
  public Solver RK4 = new Solver(); 

  public void SetAbsoluteErrorIntegral()
  {
    method = errorMethod.absolute;
  }
  public void SetSquareErrorIntegral()
  {
    method = errorMethod.square;
  }

}
