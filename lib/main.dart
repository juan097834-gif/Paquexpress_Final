import 'dart:io';
import 'package:flutter/foundation.dart'; // Para detectar kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
// Librerías de Mapa
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Paquexpress',
  theme: ThemeData(
    // VOLVEMOS AL TEMA ÍNDIGO ORIGINAL
    primarySwatch: Colors.indigo,
    scaffoldBackgroundColor: Colors.grey.shade100,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
      )
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIconColor: Colors.indigo,
    ),
  ),
  home: const LoginScreen()
));

// --- AJUSTA TU IP AQUÍ ---
const String baseUrl = "http://localhost:8000";

// ==========================================
// 1. PANTALLA DE LOGIN (ESTILO ORIGINAL)
// ==========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({ "username": _userController.text, "password": _passController.text }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen(agenteId: data['user_id'], nombreAgente: data['nombre'])));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Credenciales incorrectas"), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error de conexión")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.indigo.shade50),
                child: const Icon(Icons.local_shipping_rounded, size: 80, color: Colors.indigo),
              ),
              const SizedBox(height: 20),
              const Text("PAQUEXPRESS", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const Text("Iniciar Sesión", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 25),
                      TextField(controller: _userController, decoration: const InputDecoration(labelText: "Usuario", prefixIcon: Icon(Icons.person))),
                      const SizedBox(height: 20),
                      TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña", prefixIcon: Icon(Icons.lock))),
                      const SizedBox(height: 30),
                      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _login, child: const Text("INGRESAR"))),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text("¿No tienes cuenta? Regístrate aquí"),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. PANTALLA DE REGISTRO
// ==========================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Todos los campos son obligatorios")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({ "username": _userController.text, "password": _passController.text, "nombre": _nameController.text }),
      );
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Cuenta creada! Inicia sesión."), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al registrar"), backgroundColor: Colors.red));
      }
    } catch (e) {
       if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error de conexión")));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 60, color: Colors.indigo),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nombre Completo", prefixIcon: Icon(Icons.badge))),
            const SizedBox(height: 15),
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Usuario Nuevo", prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 15),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "Contraseña", prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _register, child: const Text("REGISTRARSE"))),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 3. PANTALLA PRINCIPAL
// ==========================================
class HomeScreen extends StatefulWidget {
  final int agenteId;
  final String? nombreAgente;
  const HomeScreen({super.key, required this.agenteId, this.nombreAgente});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List paquetes = [];
  @override
  void initState() { super.initState(); _cargarPaquetes(); }

  Future<void> _cargarPaquetes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/paquetes/${widget.agenteId}'));
      if (response.statusCode == 200) setState(() => paquetes = jsonDecode(response.body));
    } catch (e) { print(e); }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Entregas"),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)]
      ),
      body: Column(
        children: [
          if(widget.nombreAgente != null)
             Container(
               padding: const EdgeInsets.all(15),
               width: double.infinity,
               color: Colors.indigo.shade50,
               child: Text("Hola, ${widget.nombreAgente}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
             ),
          Expanded(
            child: paquetes.isEmpty 
              ? const Center(child: Text("¡Todo entregado!", style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: paquetes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = paquetes[index];
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.indigo, child: Icon(Icons.inventory_2, color: Colors.white)),
                        title: Text(p['direccion'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Para: ${p['destinatario']}"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EntregaScreen(paquete: p))).then((_) => _cargarPaquetes()),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. PANTALLA DE ENTREGA (FUNCIONALIDAD COMPLETA)
// ==========================================
class EntregaScreen extends StatefulWidget {
  final dynamic paquete;
  const EntregaScreen({super.key, required this.paquete});
  @override
  State<EntregaScreen> createState() => _EntregaScreenState();
}

class _EntregaScreenState extends State<EntregaScreen> {
  XFile? _image; 
  Position? _position;
  bool _isLoading = false;
  late LatLng _dest; 
  List<LatLng> _routePoints = []; 

  @override
  void initState() {
    super.initState();
    double lat = double.tryParse(widget.paquete['lat_dest'].toString()) ?? 25.6866;
    double lng = double.tryParse(widget.paquete['lng_dest'].toString()) ?? -100.3161;
    _dest = LatLng(lat, lng);
  }

  Future<void> _obtenerUbicacion() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() { _position = position; });
      _getRoute(LatLng(position.latitude, position.longitude), _dest);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error GPS: $e")));
    }
  }

  Future<void> _getRoute(LatLng start, LatLng end) async {
    final url = Uri.parse('https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&overview=full');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<dynamic> coords = data['routes'][0]['geometry']['coordinates'];
        setState(() => _routePoints = coords.map((c) => LatLng(c[1], c[0])).toList());
      }
    } catch (e) { print("Error ruta: $e"); }
  }

  Future<void> _tomarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) setState(() => _image = pickedFile);
  }

  Future<void> _finalizarEntrega() async {
    if (_image == null || _position == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Debes tomar foto y ver la ruta primero.")));
      return;
    }
    setState(() => _isLoading = true);
    
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/entregar'));
    request.fields['id_paquete'] = widget.paquete['id'].toString();
    request.fields['latitud'] = _position!.latitude.toString();
    request.fields['longitud'] = _position!.longitude.toString();
    if (kIsWeb) {
      var bytes = await _image!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'evidencia.jpg'));
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', _image!.path));
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Entrega Exitosa!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error al subir")));
      }
    } catch (e) { print(e); }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Validar Entrega")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // MAPA (Estilo limpio)
            ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              child: SizedBox(
                height: 350, 
                width: double.infinity,
                child: FlutterMap(
                  options: MapOptions(initialCenter: _dest, initialZoom: 13.0),
                  children: [
                    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.paquexpress.app'),
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(polylines: [Polyline(points: _routePoints, strokeWidth: 5.0, color: Colors.blue)]),
                    MarkerLayer(markers: [
                      Marker(point: _dest, width: 80, height: 80, child: const Icon(Icons.location_on, color: Colors.red, size: 50)),
                      if (_position != null)
                        Marker(point: LatLng(_position!.latitude, _position!.longitude), width: 80, height: 80, child: const Icon(Icons.my_location, color: Colors.indigo, size: 40)),
                    ])
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Destino:", style: TextStyle(color: Colors.grey)),
                          Text(widget.paquete['direccion'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // BOTÓN RUTA (Azul clásico)
                  InkWell(
                    onTap: _obtenerUbicacion,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _routePoints.isEmpty ? Colors.blue.shade50 : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blue)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions, color: Colors.blue.shade800),
                          const SizedBox(width: 10),
                          Text(_routePoints.isEmpty ? "Toca para ver ruta" : "Ruta Calculada", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade900)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // FOTO
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 200, maxHeight: 450),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300)
                    ),
                    child: _image == null
                      ? Column(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(Icons.camera_alt, size: 50, color: Colors.grey), SizedBox(height: 10), Text("Foto de evidencia")])
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: kIsWeb ? Image.network(_image!.path, fit: BoxFit.contain) : Image.file(File(_image!.path), fit: BoxFit.contain),
                        ),
                  ),
                  
                  const SizedBox(height: 10),
                  ElevatedButton.icon(icon: const Icon(Icons.camera_alt), label: const Text("Tomar Foto"), onPressed: _tomarFoto, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800)),
                  const SizedBox(height: 30),

                  // BOTÓN FINAL (Verde)
                  _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
                        onPressed: _finalizarEntrega,
                        child: const Text("FINALIZAR ENTREGA"),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}