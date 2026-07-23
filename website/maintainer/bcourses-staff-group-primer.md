# Primer: create the bCourses staff group for the 8 GB DataHub subset

> **Superseded for SOC-N100 Summer 2026.** DataHub granted RAM via `enrollment_type::teacher` / `::ta` (8G) and `::student` (4G) in [#8336](https://github.com/berkeley-dsep-infra/datahub/pull/8336) — no custom group was created. Keep this primer for **future** courses where staff prefer an explicit bCourses group subset instead of enrollment-type keys. Aaron’s 8G tier this term depends on a **Teacher or TA** role in course 1555635.

**Why (historical):** the DataHub RAM template has no per-role tier. The [curriculum guide](https://curriculum-guide.datahub.berkeley.edu/support/memory-cpu/) says extra RAM can target "a subset of students that have been placed into a bCourses group" — so one path to give Tim and Aaron (plus any TA) 8 GB while the class default stays 4 GB is a bCourses group that DataHub staff key the higher limit to. The group name would go into the request’s “additional information” **before** filing.

## Who can do this

Creating groups requires a **Teacher or TA role** in bCourses course 1555635. Tim (instructor of record) can do it directly; if Aaron should do it, Tim first adds Aaron to the course (People → +People, role TA or Designer).

## Steps (~2 minutes, in bCourses)

1. Open the course groups page: <https://bcourses.berkeley.edu/courses/1555635/groups>
   (same as course → **People** → **Groups** tab)
2. Click **+ Group Set**. Name the set: `DataHub RAM tiers`
   - Leave self sign-up **off** and group structure "I'll create groups manually" — this group controls infrastructure, students must not be able to join. ([Canvas guide: add a group set](https://community.canvaslms.com/t5/Instructor-Guide/How-do-I-add-a-group-set-in-a-course/ta-p/1157))
3. Inside the new set, click **+ Group**. Name the group: `SOC-N100 Staff 8GB`
   ([Canvas guide: manually create groups](https://community.canvaslms.com/t5/Instructor-Guide/How-do-I-manually-create-groups-in-a-group-set/ta-p/700))
4. Drag/assign members into the group: **Tim Thomas, Aaron Culich**, and any TA.
   - Note: Canvas group membership pickers list *students* by default; instructor/TA accounts sometimes need to be added via the group's **Manage → Edit** or may require the person to hold a student-visible enrollment. If Tim/Aaron don't appear in the picker, ask DataHub staff on the issue whether they can key the 8 GB tier to CalNet IDs instead — they have done per-user grants before.
5. Copy the exact **group set and group names** into the placeholder in
   [`datahub-resource-request-draft.md`](datahub-resource-request-draft.md):
   `DataHub RAM tiers / SOC-N100 Staff 8GB`

## Also verify while you're in bCourses

- Course **1555635** must be **Published** (Settings: <https://bcourses.berkeley.edu/courses/1555635/settings>, or the Publish button on the course home). The hub reads enrollments from bCourses; an unpublished course blocks the whole RAM grant, not just the staff subset.

## After the group exists

- Tick the checklist item in [`datahub-resource-request-draft.md`](datahub-resource-request-draft.md) and fill the group name into the "Additional information" paragraph.
- Tick the matching item in [`../../syllabus_TODO.md`](../../syllabus_TODO.md) (DATAHUB RAM section).
