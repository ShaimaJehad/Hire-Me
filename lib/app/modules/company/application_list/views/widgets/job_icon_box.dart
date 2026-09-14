import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hire_me/app/modules/company/application_list/model/company_job_model.dart';
import 'package:hire_me/core/utils/app_color.dart';

class JobIconBox extends StatelessWidget {
  final CompanyJobModel job;

  const JobIconBox({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final imageUrl = job.displayImageUrl;
    final icon = _iconForJob(job.title, job.mainFieldName);

    return Container(
      width: 62,
      height: 62,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColor.kblue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.kblue.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: AppColor.kblue.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.kblue,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return _fallbackIcon(icon);
                },
              )
            : _fallbackIcon(icon),
      ),
    );
  }

  Widget _fallbackIcon(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColor.kblue.withValues(alpha: 0.90),
            AppColor.kblue.withValues(alpha: 0.62),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColor.kwhite, size: 28),
    );
  }

  IconData _iconForJob(String title, String field) {
    final text = '${title.toLowerCase()} ${field.toLowerCase()}';

    if (text.contains('flutter')) return Icons.flutter_dash_rounded;
    if (text.contains('web')) return Icons.code_rounded;
    if (text.contains('design')) return Icons.brush_outlined;
    if (text.contains('data')) return Icons.storage_outlined;
    if (text.contains('marketing')) return Icons.campaign_outlined;
    if (text.contains('writing')) return Icons.edit_note_rounded;
    if (text.contains('video')) return Icons.movie_creation_outlined;

    return Icons.business_center_outlined;
  }
}
