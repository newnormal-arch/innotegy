import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:innotegy/models/farm_model.dart';
import 'package:innotegy/services/kml_service.dart';
import 'package:innotegy/widgets/app_sidebar.dart';
import 'farm_details_screen.dart';

class FarmScreen
    extends
        StatefulWidget {
  const FarmScreen({
    super.key,
  });

  @override
  State<
    FarmScreen
  >
  createState() => _FarmScreenState();
}

class _FarmScreenState
    extends
        State<
          FarmScreen
        > {
  final String _myMapsId = '16V-t8nIWuYbt5LpNzJYxa_TDshAZCiA';
  final TextEditingController _searchController = TextEditingController();

  List<
    FarmModel
  >
  _farms = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  String _selectedSort = 'name_asc';

  @override
  void initState() {
    super.initState();
    _loadAllFarmsFromMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _loadAllFarmsFromMap() async {
    setState(
      () {
        _isLoading = true;
        _errorMessage = null;
      },
    );

    try {
      final fetchedFarms = await KmlService.fetchMyMapsFarms(
        _myMapsId,
      );
      setState(
        () {
          _farms = fetchedFarms;
          _isLoading = false;
        },
      );
    } catch (
      e
    ) {
      setState(
        () {
          _errorMessage = e.toString().replaceAll(
            'Exception: ',
            '',
          );
          _isLoading = false;
        },
      );
    }
  }

  List<
    FarmModel
  >
  get _filteredAndSortedFarms {
    List<
      FarmModel
    >
    list = _farms.where(
      (
        farm,
      ) {
        final name = farm.name.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(
          query,
        );
      },
    ).toList();

    list.sort(
      (
        a,
        b,
      ) {
        switch (_selectedSort) {
          case 'name_asc':
            return a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            );
          case 'name_desc':
            return b.name.toLowerCase().compareTo(
              a.name.toLowerCase(),
            );
          case 'size_asc':
            return a.areaInHectares.compareTo(
              b.areaInHectares,
            );
          case 'size_desc':
            return b.areaInHectares.compareTo(
              a.areaInHectares,
            );
          default:
            return 0;
        }
      },
    );

    return list;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isDesktop =
        MediaQuery.of(
          context,
        ).size.width >=
        1024;
    final displayFarms = _filteredAndSortedFarms;

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ),
      drawer: isDesktop
          ? null
          : const AppSidebarDrawer(
              activeRoute: 'Farm Details',
            ),
      body: Column(
        children: [
          const _TopNavBar(),
          Expanded(
            child: Row(
              children: [
                if (isDesktop)
                  const SizedBox(
                    width: 220,
                    child: AppSidebarContent(
                      activeRoute: 'Farm Details',
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(
                      24.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Title & Map Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Farms (${_farms.length})',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(
                                      0xFF1A1A1A,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Pulled directly from Google My Maps layers.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Color(
                                  0xFF1CB026,
                                ),
                              ),
                              onPressed: _loadAllFarmsFromMap,
                              tooltip: 'Sync Map Layers',
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        // Search & Filter Bar
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search farm name...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 13,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        8,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        8,
                                      ),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                    ),
                                  ),
                                  onChanged:
                                      (
                                        val,
                                      ) => setState(
                                        () => _searchQuery = val,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Container(
                              height: 40,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                ),
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child:
                                    DropdownButton<
                                      String
                                    >(
                                      value: _selectedSort,
                                      icon: const Icon(
                                        Icons.sort,
                                        size: 18,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'name_asc',
                                          child: Text(
                                            'Name (A - Z)',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'name_desc',
                                          child: Text(
                                            'Name (Z - A)',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'size_asc',
                                          child: Text(
                                            'Size (Smallest)',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'size_desc',
                                          child: Text(
                                            'Size (Largest)',
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged:
                                          (
                                            val,
                                          ) {
                                            if (val !=
                                                null)
                                              setState(
                                                () => _selectedSort = val,
                                              );
                                          },
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),

                        // Farm Card Grid Content State
                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(
                                      0xFF1CB026,
                                    ),
                                  ),
                                )
                              : _errorMessage !=
                                    null
                              ? Center(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                              : displayFarms.isEmpty
                              ? Center(
                                  child: Text(
                                    _searchQuery.isEmpty
                                        ? 'No farms available.'
                                        : 'No farms found matching "$_searchQuery"',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _loadAllFarmsFromMap,
                                  child: LayoutBuilder(
                                    builder:
                                        (
                                          context,
                                          constraints,
                                        ) {
                                          final double width = constraints.maxWidth;
                                          final int crossAxisCount =
                                              width >
                                                  1100
                                              ? 3
                                              : (width >
                                                        700
                                                    ? 2
                                                    : 1);

                                          return GridView.builder(
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: crossAxisCount,
                                              crossAxisSpacing: 20,
                                              mainAxisSpacing: 20,
                                              mainAxisExtent: 280,
                                            ),
                                            itemCount: displayFarms.length,
                                            itemBuilder:
                                                (
                                                  context,
                                                  index,
                                                ) {
                                                  final farm = displayFarms[index];
                                                  return _FarmCard(
                                                    farm: farm,
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => FarmDetailsScreen(
                                                                farm: farm,
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                          );
                                        },
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Farm Card Component Matching Design Spec
class _FarmCard
    extends
        StatelessWidget {
  final FarmModel farm;
  final VoidCallback onTap;

  const _FarmCard({
    required this.farm,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            12,
          ),
          border: Border.all(
            color: const Color(
              0xFFEFEFEF,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.02,
              ),
              blurRadius: 8,
              offset: const Offset(
                0,
                2,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF1CB026,
                        ),
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Text(
                        'Healthy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(
                16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          farm.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(
                              0xFF1A1A1A,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.north_east,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.crop_free,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        '${farm.areaInHectares.toStringAsFixed(1)} Hectares',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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

class _TopNavBar
    extends
        StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isDesktop =
        MediaQuery.of(
          context,
        ).size.width >=
        1024;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(
              0xFFEFEFEF,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(
                Icons.menu,
              ),
              onPressed: () => Scaffold.of(
                context,
              ).openDrawer(),
            ),
          const Spacer(),
          if (currentUser !=
              null)
            StreamBuilder<
              DocumentSnapshot<
                Map<
                  String,
                  dynamic
                >
              >
            >(
              stream: FirebaseFirestore.instance
                  .collection(
                    'users',
                  )
                  .doc(
                    currentUser.uid,
                  )
                  .snapshots(),
              builder:
                  (
                    context,
                    snapshot,
                  ) {
                    String fullName = 'User';
                    String userRole = 'Farmer';

                    if (snapshot.hasData &&
                        snapshot.data!.exists) {
                      final data = snapshot.data!.data();
                      fullName =
                          data?['fullName'] ??
                          'User';
                      userRole =
                          data?['userRole'] ??
                          'Farmer';
                    }

                    return Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userRole,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/100?img=68',
                          ),
                        ),
                      ],
                    );
                  },
            ),
        ],
      ),
    );
  }
}

class _SidebarContent
    extends
        StatelessWidget {
  final String activeRoute;

  const _SidebarContent({
    required this.activeRoute,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(
              0xFFEFEFEF,
            ),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 12,
        ),
        children: [
          _SidebarItem(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            isActive:
                activeRoute ==
                'Dashboard',
          ),
          _SidebarItem(
            icon: Icons.bar_chart_rounded,
            label: 'Reports',
            isActive:
                activeRoute ==
                'Reports',
          ),
          _SidebarItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isActive:
                activeRoute ==
                'Settings',
          ),
          _SidebarItem(
            icon: Icons.map_outlined,
            label: 'Farm Details',
            isActive:
                activeRoute ==
                'Farm Details',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (
                        context,
                      ) => const FarmScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SidebarDrawer
    extends
        StatelessWidget {
  const _SidebarDrawer();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Drawer(
      child: SafeArea(
        child: _SidebarContent(
          activeRoute: 'Farm Details',
        ),
      ),
    );
  }
}

class _SidebarItem
    extends
        StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(
                0xFFF2F2F2,
              )
            : Colors.transparent,
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: isActive
              ? Colors.black
              : Colors.grey[600],
        ),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive
                ? FontWeight.bold
                : FontWeight.w500,
            color: isActive
                ? Colors.black
                : Colors.grey[700],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
