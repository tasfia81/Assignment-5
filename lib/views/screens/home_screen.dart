import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/deck_repository.dart';
import '../../data/models/flash_deck_model.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeckRepository _deckRepository = Get.find<DeckRepository>();
  late Future<List<FlashDeck>> _decksFuture;

  @override
  void initState() {
    super.initState();
    _decksFuture = _deckRepository.getDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.h),
                ///------------------------------------ Header/Title ------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            'FlashSwipe',
                            style: AppTextStyles.h1.copyWith(
                              color: Colors.white, // Required for ShaderMask
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Khizex App Build Challenge',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
                      ),
                      child: Icon(
                        Icons.bolt,
                        color: AppColors.glow,
                        size: 24.r,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32.h),
                
                ///------------------------------------ Section Title ------------------------------------
                Text(
                  'Your Decks',
                  style: AppTextStyles.h2,
                ),
                SizedBox(height: 16.h),
                
                ///------------------------------------ Deck List ------------------------------------
                Expanded(
                  child: FutureBuilder<List<FlashDeck>>(
                    future: _decksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        );
                      }
                      
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error loading decks',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                          ),
                        );
                      }
                      
                      final decks = snapshot.data ?? [];
                      if (decks.isEmpty) {
                        return Center(
                          child: Text(
                            'No decks available.',
                            style: AppTextStyles.bodyMedium,
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        itemCount: decks.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final deck = decks[index];
                          return _buildDeckCard(deck);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeckCard(FlashDeck deck) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: GestureDetector(
        onTap: () => _startDeckSession(deck),
        child: GlassContainer(
          padding: EdgeInsets.all(20.r),
          hasGlow: true,
          glowColor: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge & Card Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'STUDY DECK',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.style_outlined,
                        color: AppColors.textSecondary,
                        size: 16.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${deck.cards.length} Cards',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              
              // Deck Name
              Text(
                deck.name,
                style: AppTextStyles.h3,
              ),
              SizedBox(height: 8.h),
              
              // Deck Description
              Text(
                deck.description,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20.h),
              
              // Action Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Practice',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 16.r,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startDeckSession(FlashDeck deck) {
    // Get SessionViewModel, start session, and route to session screen
    final SessionViewModel sessionVM = Get.find<SessionViewModel>();
    sessionVM.startSession(deck);
    Get.toNamed('/session');
  }
}
