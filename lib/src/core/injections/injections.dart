import 'package:get_it/get_it.dart';
import 'package:iveco_find/src/core/services/dio_client.dart';
import 'package:iveco_find/src/core/services/i_local_storage.dart';
import 'package:iveco_find/src/modules/auth/controllers/auth_controller.dart';
import 'package:iveco_find/src/modules/home/controllers/home_controller.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/controllers/add_or_edit_supplier_controller.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/controllers/supplier_controller.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/location/controllers/add_or_edit_location_controller.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/location/controllers/add_or_edit_section_controller.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/location/controllers/location_controller.dart';
import 'package:iveco_find/src/modules/home/pages/supplier/location/controllers/location_details_controller.dart';
import 'package:iveco_find/src/modules/home/pages/types/controllers/add_or_edit_type_controller.dart';
import 'package:iveco_find/src/modules/home/pages/types/controllers/types_controller.dart';
import 'package:iveco_find/src/shared/repositories/auth_repository.dart';
import 'package:iveco_find/src/shared/repositories/location_repository.dart';
import 'package:iveco_find/src/shared/repositories/section_repository.dart';
import 'package:iveco_find/src/shared/repositories/supplier_repository.dart';
import 'package:iveco_find/src/shared/repositories/types_repository.dart';

class Injections {
  static void inittialized() {
    //LOCALSTORAGE
    GetIt.instance.registerSingleton<LocalStorage>(LocalStorage());

    //DIO
    GetIt.instance.registerSingleton<ClientDio>(
      ClientDio(storage: GetIt.instance.get<LocalStorage>()),
    );

    //REPOSITORIES
    GetIt.instance.registerSingleton<AuthRepository>(
      AuthRepository(dio: GetIt.instance.get<ClientDio>()),
    );

    GetIt.instance.registerSingleton<TypesRepository>(
      TypesRepository(dio: GetIt.instance.get<ClientDio>()),
    );
    GetIt.instance.registerSingleton<SupplierRepository>(
      SupplierRepository(dio: GetIt.instance.get<ClientDio>()),
    );
    GetIt.instance.registerSingleton<LocationRepository>(
      LocationRepository(dio: GetIt.instance.get<ClientDio>()),
    );
    GetIt.instance.registerSingleton<SectionRepository>(
      SectionRepository(dio: GetIt.instance.get<ClientDio>()),
    );

    //CONTROLLER
    GetIt.instance.registerSingleton<AuthController>(
      AuthController(
        repository: GetIt.instance.get<AuthRepository>(),
        storage: GetIt.instance.get<LocalStorage>(),
      ),
    );

    GetIt.instance.registerSingleton<HomeController>(
      HomeController(
        authRepository: GetIt.instance.get<AuthRepository>(),
        storage: GetIt.instance.get<LocalStorage>(),
      ),
    );

    GetIt.instance.registerSingleton<TypesController>(
      TypesController(typesRepository: GetIt.instance.get<TypesRepository>()),
    );
    GetIt.instance.registerSingleton<AddOrEditTypeController>(
      AddOrEditTypeController(
        repository: GetIt.instance.get<TypesRepository>(),
      ),
    );
    GetIt.instance.registerSingleton<SupplierController>(
      SupplierController(repository: GetIt.instance.get<SupplierRepository>()),
    );

    GetIt.instance.registerSingleton<AddOrEditSupplierController>(
      AddOrEditSupplierController(
        repository: GetIt.instance.get<SupplierRepository>(),
      ),
    );

    GetIt.instance.registerSingleton<LocationController>(
      LocationController(repository: GetIt.instance.get<LocationRepository>()),
    );
    GetIt.instance.registerSingleton<AddOrEditLocationController>(
      AddOrEditLocationController(
        repository: GetIt.instance.get<LocationRepository>(),
      ),
    );
    GetIt.instance.registerSingleton<LocationDetailsController>(
      LocationDetailsController(
        repository: GetIt.instance.get<SectionRepository>(),
      ),
    );
    GetIt.instance.registerSingleton<AddOrEditSectionController>(
      AddOrEditSectionController(
        repository: GetIt.instance.get<SectionRepository>(),
      ),
    );
  }
}
