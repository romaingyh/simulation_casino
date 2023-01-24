import 'package:scidart/numdart.dart';

enum DistributionType {
  exp1("Exponentielle λ = 1"),
  exp5("Exponentielle λ = 5"),
  discret("Loi discrète d'éspérance 10");

  final String name;

  const DistributionType(this.name);
}

extension DistributionTypeX on DistributionType {
  Array simulate(int size) {
    var u = randomArray(size);

    switch (this) {
      case DistributionType.exp1:
        return arrayMultiplyToScalar(arrayLog(u), -1);
      case DistributionType.exp5:
        return arrayMultiplyToScalar(arrayLog(u), -1 / 5);
      case DistributionType.discret:
        var v = zeros(size);
        for (var i = 0; i < size; i++) {
          if (u[i] <= 0.33) {
            v[i] = 4;
          } else {
            v[i] = 13;
          }
        }
        return v;
    }
  }
}
