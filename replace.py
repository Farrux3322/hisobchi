import re

with open("lib/presentation/pages/client/client_list_page.dart", "r") as f:
    text = f.read()

# 1. Remove the SliverToBoxAdapter chunk for PartnerReportWidget
text = re.sub(
    r"                    SliverToBoxAdapter\([\s\S]*?child:\s*PartnerReportWidget\([\s\S]*?Navigator\.push\(context, MaterialPageRoute\(builder: \(_\) => const ReportClientMainPage\(\)\)\);[\s\S]*?\},[\s\S]*?\),[\s\S]*?\),",
    "",
    text
)

# 2. Replace the FAB starting structure
fab_replacement = """              floatingActionButton: SubscriptionGuard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 56.w,
                      height: 56.w,
                      child: FloatingActionButton(
                        tooltip: "Mijozlar hisoboti",
                        heroTag: 'client_report_fab',
                        elevation: 4,
                        onPressed: () {
                          if (!context.hasPermission('report_partners.view')) {
                            Toast.showWarningToast(message: "Sizda bunday huquq yo'q");
                            return;
                          }
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportClientMainPage()));
                        },
                        backgroundColor: AppTheme.colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                          side: BorderSide(color: AppTheme.colors.primary.withValues(alpha: 0.1), width: 1.5),
                        ),
                        child: Icon(Icons.analytics_rounded, color: AppTheme.colors.primary, size: 28.sp),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: 56.w,
                      height: 56.w,
                      child: FloatingActionButton(
                        heroTag: 'client_fab',"""

text = re.sub(
    r"              floatingActionButton:\s*SubscriptionGuard\(\s*child:\s*SizedBox\(\s*width:\s*56\.w,\s*height:\s*56\.w,\s*child:\s*FloatingActionButton\(\s*heroTag:\s*'client_fab',",
    fab_replacement,
    text
)

# 3. Replace the FAB closing structure
closing_to_replace = """                    backgroundColor: AppTheme.colors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                    child: Icon(Icons.add, color: Colors.white, size: 36.sp),
                  ),
                ),
              ),"""
              
with_closing = """                        backgroundColor: AppTheme.colors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                        child: Icon(Icons.add, color: Colors.white, size: 36.sp),
                      ),
                    ),
                  ],
                ),
              ),"""
text = text.replace(closing_to_replace, with_closing)

# Write back
with open("lib/presentation/pages/client/client_list_page.dart", "w") as f:
    f.write(text)
print("Transformation Complete")
