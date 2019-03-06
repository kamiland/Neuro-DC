public class Controller
{
  public double Kp, Ki, Kd;
  double P, I, D;
  double integral, derivative;
  double error, preError = 0, controllerOutput = 0;
  int minOutput;
  int maxOutput;
  boolean saturation = false;

  public Controller()
  {
  }

  public Controller(double _Kp, double _Ki, double _Kd)
  {
    Kp = _Kp;
    Ki = _Ki;
    Kd = _Kd;
  }

  public Controller(double _Kp, double _Ki, double _Kd, int _minOutput, int _maxOutput)
  {
    saturation = true;
    Kp = _Kp;
    Ki = _Ki;
    Kd = _Kd;
    minOutput = _minOutput;
    maxOutput = _maxOutput;
  }

  public double CalculateOutput(double setpoint, double pv, double dt)
  {
    error = setpoint - pv;

    P = Kp * error;

    integral += error * dt;
    I = Ki * integral;

    derivative = (error - preError) / dt;
    D = Kd * derivative;

    preError = error;

    controllerOutput = P + I + D;

    if (true == saturation)
    {
      if (controllerOutput > maxOutput) controllerOutput = maxOutput;
      if (controllerOutput < minOutput) controllerOutput = minOutput;
    }

    return controllerOutput;
  }
}
