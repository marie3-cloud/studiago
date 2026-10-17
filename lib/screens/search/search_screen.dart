import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../models/request_model.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = SupabaseService();
  List<RequestModel> _requests = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _loading = true);
    try {
      final user = context.read<AuthProvider>().user;
      final requests = await _supabase.getRequests(
        studyYear: user?.studyYear,
        studyAddress: user?.studyAddress,
      );
      if (mounted) {
        setState(() {
          _requests = requests;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerca & Richieste'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'Richieste'),
            Tab(text: 'Cerca materiale'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push('/search/create-request'),
            tooltip: 'Nuova richiesta',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Richieste
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: _requests.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.help_outline,
                                        size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Nessuna richiesta attiva',
                                      style: TextStyle(
                                          color: AppTheme.textSecondary),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () => context
                                          .push('/search/create-request'),
                                      child: const Text('Crea una richiesta'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80, top: 8),
                          itemCount: _requests.length,
                          itemBuilder: (context, i) {
                            final req = _requests[i];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(14),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppTheme.accent.withOpacity(0.15),
                                  child: const Icon(Icons.help_outline,
                                      color: AppTheme.accent),
                                ),
                                title: Text(
                                  req.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      '${req.subject} · ${req.authorName ?? "Utente"}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(req.createdAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: req.status == 'open'
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              AppTheme.success.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'Aperta',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppTheme.success,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    : null,
                                onTap: () => context
                                    .push('/search/request/${req.id}'),
                              ),
                            );
                          },
                        ),
                ),

          // Tab Cerca materiale (semplice redirect a notes con ricerca)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_rounded,
                      size: 72, color: AppTheme.primary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'Cerca materiale didattico',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vai nella sezione Appunti per cercare\nper titolo, materia o filtro',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/notes'),
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Vai agli Appunti'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
